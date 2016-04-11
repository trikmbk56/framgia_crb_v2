namespace :db do
  desc "remake database data"
  task remake_data: :environment do

    if Rails.env.production?
      puts "Not running in 'Production' task"
    else
      %w[db:drop db:create db:migrate db:seed db:test:prepare].each do |task|
        Rake::Task[task].invoke
      end

      puts "Creating User"
      user = Fabricate :user

      puts "Creating Calendar"
      calendar = Fabricate :calendar, user_id: user.id

      puts "Creating event"
      5.times do |i|
        date_time = DateTime.now + i.days
        start_time_day = date_time.change({hour: 8})
        end_time_day = date_time.change({hour: 10})
        Fabricate :event, start_time: start_time_day, finish_time: end_time_day,
          calendar_id: calendar.id, user_id: user.id
      end
    end
  end
end
