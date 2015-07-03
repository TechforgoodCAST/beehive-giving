workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection

  # Enable New Relic RPM
  # https://github.com/puma/puma/issues/128#issuecomment-21050609
  require 'newrelic_rpm'
  NewRelic::Agent.manual_start
end
