class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.references :user
      t.string :name
      t.string :description
      t.references :color
      t.integer :parent_id

      t.timestamps null: false
    end

    add_index :calendars, :parent_id
  end
end
