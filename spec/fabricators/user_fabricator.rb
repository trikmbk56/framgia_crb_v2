Fabricator :user do
  name {Faker::Name.name}
  email {sequence(:email) {|i| "user#{i}@crb.com"}}
  password "12345678"
end
