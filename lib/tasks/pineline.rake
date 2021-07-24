namespace :pipeline do
    desc "TODO"
    task prospecting: :environment do
        Lead.check_pending_prospecting
    end
  
    task demo: :environment do
        Lead.check_pending_demo
    end
  end
  