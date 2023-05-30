#!/bin/bash
# Read in the file of environment settings
. $HOME/.bashrc

envsubst < /home/openolat/lib/olat.local.properties.template > /home/openolat/lib/olat.local.properties

# Then run the CMD
exec "$@"