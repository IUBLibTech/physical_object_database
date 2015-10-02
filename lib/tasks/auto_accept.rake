# auto_accept.rake
# Rake tasks for quality control auto_accept
#
# Example use:
# rake qc:auto_accept
#
namespace :qc do
  desc "Auto-accept audio and video files past 30/40-day window"
    task :auto_accept, [:type] => :environment do |task, args|
      DigitalFileAutoAcceptor.instance.auto_accept
    end
end
