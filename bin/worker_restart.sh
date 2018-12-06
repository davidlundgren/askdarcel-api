#!/bin/bash

# Use whenever gem to update crontab from config/schedule.rb
whenever --update-crontab

# Restart delayed_job worker process
./bin/delayed_job restart
