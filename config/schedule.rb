# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 30.minutes do
  runner 'MetadataServer.sync_all'
end

every 15.minutes do
  runner 'ApiServer.first.sync_ss_servers'
  runner 'ApiServer.first.sync_tunnel_server'
end

every 1.day do
  runner 'Gateway::DNS.instance.update_china_domains_list'
end
