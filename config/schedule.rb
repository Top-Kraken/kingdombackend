set :output, "log/whenever.log"
set :bundle_command, "/usr/local/bin/bundle exec"
env :PATH, ENV['PATH']

every 5.minutes do
  # command 'Lead.check_pending_prospecting'
  rake 'pipeline:prospecting'
end

every 5.minutes do
  # command 'Lead.check_pending_demo'
  rake 'pipeline:demo'
end