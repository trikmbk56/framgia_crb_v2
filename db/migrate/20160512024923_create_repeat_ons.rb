class CreateRepeatOns < ActiveRecord::Migration
  def change
    create_table :repeat_ons do |t|
      t.references :event
      t.references :days_of_week
      t.timestamps null: false
    end
  end
end
