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

      puts "Create permission"
      read_permission = Fabricate :permission, permission: "read"
      edit_permission = Fabricate :permission, permission: "edit"

      puts "Creating more users"
      5.times do
        user = Fabricate :user
        puts "Shared calendar"
        Fabricate :user_calendar, calendar_id: calendar.id, user_id: user.id,
          permission_id: read_permission.id
      end

      puts "Creating event"
      10.times do |i|
        date_time = DateTime.now + i.days
        start_time_day = date_time.change({hour: 8})
        end_time_day = date_time.change({hour: 10})
        event = Fabricate :event, start_time: start_time_day,
          finish_time: end_time_day, calendar_id: calendar.id, user_id: user.id
        Fabricate :attendee, user_id: 2, event_id: event.id
      end
    end
  end
end
