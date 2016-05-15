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
      Fabricate :permission, permission: I18n.t("permissions.permission_1")
      Fabricate :permission, permission: I18n.t("permissions.permission_2")
      Fabricate :permission, permission: I18n.t("permissions.permission_3")
      Fabricate :permission, permission: I18n.t("permissions.permission_4")

      user_hash = {
        "Khong Minh Tri": "khong.minh.tri",
        "Bui Quoc Viet": "bui.quoc.viet",
        "Hoang Thi Nhung": "hoang.thi.nhung",
        "Nguyen Binh Dieu": "nguyen.binh.dieu",
        "Tran Quang Trung": "tran.quang.trung",
        "Dao Duy Dat": "dao.duy.dat",
        "Nguyen Thai Son": "nguyen.thai.son",
        "Lim Kimhuor": "lim.kimhuor",
        "Chu Anh Tuan": "chu.anh.tuan",
        "Ngo Thai Minh": "ngo.thai.minh",
        "Mai Dinh Phu": "mai.dinh.phus"
      }

      puts "Creating Color, User, Calendar, Share calendar, Event"

      Settings.colors.each do |color|
        Fabricate :color, color_hex: color
      end

      user_hash.each do |key, value|
        user = Fabricate :user, name: key, email: value+"@framgia.com"
        calendar = user.calendars.first

        4.times do |i|
          date_time = DateTime.now + i.days
          start_time_day = date_time.change({hour: 8})
          end_time_day = date_time.change({hour: 10})
          range = Random.rand(2...30)
          end_repeat = date_time + range.days
          repeat_type = Random.rand(1...4)
          event = Fabricate :event, start_date: start_time_day,
            finish_date: end_time_day, start_repeat: date_time,
            end_repeat: end_repeat, calendar_id: calendar.id,
            user_id: user.id, repeat_type: repeat_type

          if event.repeat_type == 2
            3.times do
              on = Random.rand(0...6)
              Fabricate :repeat_on, event_id: event.id, repeat_on: on
            end
          end

          3.times do |j|
            Fabricate :attendee, user_id: j + 1, event_id: event.id
          end
        end
      end
    end
  end
end
