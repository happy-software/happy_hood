class HelloWorldWorker
  include Sidekiq::Worker

  def perform
    puts "Hello world, it's currently #{Date.current}."
  end
end
