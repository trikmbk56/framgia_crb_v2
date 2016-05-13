class Permission < ActiveRecord::Base
  scope :be_shown, ->{where.not id: 5}
end
