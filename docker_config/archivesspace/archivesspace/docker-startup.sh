#!/bin/bash

/apps/aspace/archivesspace/scripts/setup-database.sh
if [[ "$?" != 0 ]]; then
  echo "Error running the database setup script."
  exit 1
fi

exec /apps/aspace/archivesspace/archivesspace.sh