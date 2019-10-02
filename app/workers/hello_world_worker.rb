class HelloWorldWorker
  include Sidekiq::Worker

  def perform
    puts "Hello world, it's currently #{DateTime.current}."
  end
end
