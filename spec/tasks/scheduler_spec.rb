require "rails_helper"
require "rake"

describe "scheduler.rake rake tasks" do
  let(:task) { Rake::Task[task_name] }
  let(:task_name) { "my:rake:task" }

  after(:each) do
    task.reenable
  end
end
