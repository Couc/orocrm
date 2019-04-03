#!/bin/bash
set -e

###
# Description:       Start up script for docker (Development only)
# Author:            Rui Filipe Da Cunha Alves <rui@virtua.ch>
###

exec supervisord -n -c /etc/supervisor/supervisord.conf
