#!/bin/bash

PLUGINS_DIR=/apps/aspace/archivesspace/plugins

function install_plugins {
    # disable "detached head" warnings
    git config --global advice.detachedHead false

    while read url commit name; do
        name=${name:-$(basename $url .git)}
        dir="$PLUGINS_DIR/$name"
        if [ ! -e "$dir" ]; then
            git clone "$url" "$dir"
        fi
        cd "$dir"
        git fetch
        git checkout "$commit"
    done

    # re-enable "detached head" warnings
    git config --global advice.detachedHead true
}

# install plugins
mkdir -p "$PLUGINS_DIR"
grep -v '^\s*#' /apps/aspace/config/plugins | install_plugins

# plugin customization
# tweaks the plugin to migration automagically
sed -i 's/while true/while false/' "$PLUGINS_DIR/payments_module/migrations/002_load_fund_codes.rb"

# dump all the default text notes
rm "$PLUGINS_DIR"/default_text_for_notes/config/*.txt
# copy our values
ln -sf /apps/aspace/files/*.txt "$PLUGINS_DIR/default_text_for_notes/config"

# replace the template with one that will work in ArchivesSpace 2.x
ln -sf /apps/aspace/files/_template.html.erb "$PLUGINS_DIR/default_text_for_notes/frontend/views/rights_statements"

# initialize any plugins that need Gems
for gemfile in $(find /apps/aspace/archivesspace/plugins/ -maxdepth 2 -name Gemfile); do
    plugin=$(basename $(dirname $gemfile))
    echo Initializing plugin: "$plugin"
    /apps/aspace/archivesspace/scripts/initialize-plugin.sh "$plugin"
done
