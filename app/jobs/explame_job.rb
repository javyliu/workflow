class ExplameJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    puts "this is lksdjf"
  end
end
