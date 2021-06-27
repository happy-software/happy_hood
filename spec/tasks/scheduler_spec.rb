require "rails_helper"
require "rake"

Rails.application.load_tasks

describe "scheduler.rake rake tasks" do
  let(:task) { Rake::Task[task_name] }
  let(:task_name) { "my:rake:task" }

  after(:each) do
    task.reenable
  end

  describe "monthly_price_summary" do
    let(:task_name) { "monthly_price_summary" }

    it "sends a monthly price summary" do
      expect(HappyHood::Slack::Client).to receive(:send_monthly_price_summary)

      task.invoke
    end

    it "sends the monthly price summary only once per month" do
      months = [3.months.ago, 1.month.ago]

      months.each do |month|
        Timecop.freeze(month) do
          expect(HappyHood::Slack::Client).to receive(:send_monthly_price_summary).exactly(1).time

          task.invoke
          task.reenable
        end
      end
    end
  end
end
