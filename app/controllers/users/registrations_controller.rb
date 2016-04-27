class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      Calendar.create({user_id: resource.id, name: resource.name, color_id: 1})
    end
  end
end
