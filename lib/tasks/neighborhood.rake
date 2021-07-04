namespace :neighborhood do
  desc "Generate a csv to onboard a neighborhood"
  task generate_onboarding_csv: :environment do |t|
    require "csv"

    filename = "#{DateTime.now.to_i}_onboard_neighborhood.csv"
    CSV.open(filename, "w") { |csv| csv << Hood::Onboarder::RequiredFields }

    Rails.logger.info "Created #{filename}"
  end

  desc 'Upload a CSV of a neighborhood'
  task :upload, [:onboarding_csv_path] => :environment do |t, args|
    starting_count = House.count

    csv_entries = CSV.read(
      args[:onboarding_csv_path],
      headers: true,
      header_converters: :symbol,
    ).map(&:to_h)

    if csv_entries.flat_map(&:keys).uniq != Hood::Onboarder::RequiredFields
      error = <<~ERR
      #{args[:hood_onboarding_csv_path]} does not have valid headers.
      Got: #{csv_entries.flat_map(&:keys).uniq}
      Want: #{Hood::Onboarder::RequiredFields}
      ERR

      raise ArgumentError, error
    end

    Hood::Onboarder.run(csv_entries)

    ending_count = House.count
    Rails.logger.info <<~MSG.strip
    There are #{ending_count} houses in the database now (#{ending_count-starting_count} added)
    MSG
  end
end
