class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.references :user
      t.string :name
      t.string :description
      t.references :color

      t.timestamps null: false
    end
  end
end
