Fabricator :event do
  title {Faker::Lorem.word}
  user_id
  description {Faker::Lorem.sentence}
  start_time {DateTime.new(2016,2,3,8,0,0,"+7")}
  finish_time {DateTime.new(2016,2,3,8,0,0,"+7")}
  calendar_id
end
