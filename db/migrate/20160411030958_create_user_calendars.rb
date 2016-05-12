class CreateUserCalendars < ActiveRecord::Migration
  def change
    create_table :user_calendars do |t|
      t.references :user
      t.references :calendar
      t.references :permission
      t.references :color, default: 1

      t.timestamps null: false
    end
  end
end
