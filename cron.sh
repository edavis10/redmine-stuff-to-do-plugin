#!/bin/bash

# Absolute path to your redmine installation here
REDMINE_ROOT=

# Name of your production environment (most cases "production")
RAILS_ENV=production

# These lines do the actual work
cd $REDMINE_ROOT
rake redmine:redmine_reminder:send_reminder_mails RAILS_ENV=$RAILS_ENV