require "rails_helper"
require "rake"

describe "summaries.rake rake tasks" do
  let(:task) { Rake::Task[task_name] }
  let(:task_name) { "my:rake:task" }
  let(:file_store_name) { "tmp/test_#{RSpec.current_example.metadata[:description].gsub(/\W+/, "_")[0..28]}/cache" }

  after(:each) do
    task.reenable
  end

  describe "daily" do
    let(:task_name) { "summaries:daily" }

    it "sends a daily price summary" do
      expect(HappyHood::Slack::Client).to receive(:send_daily_price_summary)

      task.invoke
    end

    context "with caching enabled" do
      before do
        file_store_cache = ActiveSupport::Cache.lookup_store(:file_store, file_store_name)
        allow(Rails).to receive(:cache).and_return(file_store_cache)
        Rails.cache.clear
      end

      it "sends the daily price summary only once per day" do
        expect(HappyHood::Slack::Client).to receive(:send_daily_price_summary).exactly(1).time

        2.times do
          task.invoke
          task.reenable
        end
      end
    end
  end

  describe "monthly" do
    let(:task_name) { "summaries:monthly" }

    it "sends a monthly price summary" do
      expect(HappyHood::Slack::Client).to receive(:send_monthly_price_summary)

      task.invoke
    end

    context "with caching enabled" do
      before do
        file_store_cache = ActiveSupport::Cache.lookup_store(:file_store, file_store_name)
        allow(Rails).to receive(:cache).and_return(file_store_cache)
        Rails.cache.clear
      end
      it "sends the monthly price summary only once per month" do
        months = [3.months.ago, 1.month.ago]

        months.each do |month|
          Timecop.freeze(month) do
            expect(HappyHood::Slack::Client).to receive(:send_monthly_price_summary).exactly(1).time

            2.times do
              task.invoke
              task.reenable
            end
          end
        end
      end
    end
  end
end
