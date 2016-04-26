namespace :db do
  desc "remake database data"
  task remake_data: :environment do

    if Rails.env.production?
      puts "Not running in 'Production' task"
    else
      %w[db:drop db:create db:migrate db:seed db:test:prepare].each do |task|
        Rake::Task[task].invoke
      end

      puts "Create permission"
      read_permission = Fabricate :permission, permission: "read"
      edit_permission = Fabricate :permission, permission: "edit"

      user_hash = {
        "Khong Minh Tri": "khong.minh.tri",
        "Bui Quoc Viet": "bui.quoc.viet",
        "Hoang Thi Nhung": "hoang.thi.nhung",
        "Nguyen Binh Dieu": "nguyen.binh.dieu",
        "Tran Quang Trung": "tran.quang.trung",
        "Dao Duy Dat": "dao.duy.dat",
        "Nguyen Thai Son": "nguyen.thai.son",
        "Lim Kimhuor": "lim.kimhour"
      }

      puts "Creating Color, User, Calendar, Share calendar, Event"

      Settings.colors.each do |color|
        Fabricate :color, color_hex: color
      end

      user_hash.each do |key, value|
        user = Fabricate :user, name: key, email: value+"@framgia.com"
        calendar = Fabricate :calendar, user_id: user.id, color_id: 1

        Fabricate :user_calendar, calendar_id: calendar.id, user_id: user.id,
          permission_id: read_permission.id

        2.times do |i|
          date_time = DateTime.now + i.days
          start_time_day = date_time.change({hour: 8})
          end_time_day = date_time.change({hour: 10})
          event = Fabricate :event, start_date: start_time_day,
            finish_date: end_time_day, calendar_id: calendar.id, user_id: user.id
          3.times do |j|
            Fabricate :attendee, user_id: j + 1, event_id: event.id
          end
        end
      end
    end
  end
end
