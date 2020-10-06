# Patch for ANW-1020 (https://archivesspace.atlassian.net/browse/ANW-1020)
#
# This file contains the methods modified in ArchivesSpace Pull Request #1795
# (https://github.com/archivesspace/archivesspace/pull/1795).
#
# This file shold be removed when the ArchivesSpace base version is updated to a
# release that contains that pull request.

module TreeNodes

  # A note on terminology: a logical position refers to the position of a node
  # as observed by the user (0...RECORD_COUNT).  A physical position is the
  # position number stored in the database, which may have gaps.
  def attempt_set_position_in_list(target_logical_position)
    DB.open do |db|
      ordered_siblings = db[self.class.node_model.table_name].filter(
        :root_record_id => self.root_record_id, :parent_id => self.parent_id
      ).order(:position)
      siblings_count = ordered_siblings.count

      target_logical_position = [target_logical_position, siblings_count - 1].min

      current_physical_position = self.position
      current_logical_position = ordered_siblings.where { position < current_physical_position }.count

      # If we are already are the correct logical position, do nothing
      return if (target_logical_position == current_logical_position)

      # We'll determine which node will fall to the left of our moved node, and
      # which will fall to the right.  We're going to set our physical position to
      # the halfway point of those two nodes.  For example, if left node is
      # position 1000 and right node is position 2000, we'll take position 1500.
      # If there's no gap, we'll create one!
      #
      left_node_idx = target_logical_position - 1

      if current_logical_position < target_logical_position
        # If the node is being moved to the right, we need to adjust our index to
        # compensate for the fact that everything logically shifts to the left as we
        # pop it out.
        left_node_idx += 1
      end

      left_node_physical_position =
        if left_node_idx < 0
          # We'll be the first item in the list (nobody to the left of us)
          nil
        else
          ordered_siblings.offset(left_node_idx).get(:position)
        end

      right_node_idx = left_node_idx + 1

      right_node_physical_position =
        if right_node_idx >= siblings_count
          # We'll be the last item in the list (nobody to the right of us)
          nil
        else
          ordered_siblings.offset(right_node_idx).get(:position)
        end

      new_position =
        if left_node_physical_position.nil? && right_node_physical_position.nil?
          # We're first in the list!
          new_position = TreeNodes::POSITION_STEP
        else
          if right_node_physical_position.nil?
            # Add to the end
            left_node_physical_position + TreeNodes::POSITION_STEP
          else
            left_node_physical_position ||= 0

            if (right_node_physical_position - left_node_physical_position) <= 1
              # We need to create a gap to fit our moved node
              right_node_physical_position = ensure_gap(right_node_physical_position)
            end

            # Put the node we're moving halfway between the left and right nodes
            left_node_physical_position + ((right_node_physical_position - left_node_physical_position) / 2)
          end
        end

      self.class.dataset.db[self.class.table_name]
        .filter(:id => self.id)
        .update(:position => new_position,
                :system_mtime => Time.now)
    end
  end

  def update_from_json(json, extra_values = {}, apply_nested_records = true)
    root_uri = self.class.uri_for(self.class.root_record_type, self.root_record_id)

    do_position_override = json[self.class.root_record_type]['ref'] != root_uri || extra_values[:force_reposition]

    if do_position_override
      extra_values.delete(:force_reposition)
      json.position = nil
      # Through some inexplicable sequence of events, the update is allowed to
      # change the root record on the fly.  I guess we'll allow this...
      extra_values = extra_values.merge(self.class.determine_tree_position_for_new_node(json))
    else
      if !json.position
        # The incoming JSON had no position set.  Just keep what we already had.
        extra_values['position'] = self.position
      end
    end

    # Save the logical position to use in setting the position further on.
    logical_position = json.position

    # Reset json.position to physical position before saving to the database
    json.position = self.position

    obj = super(json, extra_values, apply_nested_records)

    # Set json.position back to logical position for any further processing
    json.position = logical_position

    if json.position
      # Our incoming JSON wants to set the position.  That's fine
      set_position_in_list(json.position)
    end

    self.class.ensure_consistent_tree(obj)

    trigger_index_of_child_nodes

    obj
  end

end
