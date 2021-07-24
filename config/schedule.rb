set :output, "log/whenever.log"

every 5.minutes do
  # command 'Lead.check_pending_prospecting'
  rake 'pipeline:prospecting'
end

every 5.minutes do
  # command 'Lead.check_pending_demo'
  rake 'pipeline:demo'
end