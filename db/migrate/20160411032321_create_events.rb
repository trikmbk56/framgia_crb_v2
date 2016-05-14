class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :status
      t.string :color
      t.boolean :all_day, default: false
      t.integer :repeat_type
      t.integer :repeat_every
      t.references :user
      t.references :calendar
      t.datetime :start_date
      t.datetime :finish_date
      t.datetime :start_repeat
      t.datetime :end_repeat
      t.datetime :exception_time
      t.integer :parent_id

      t.timestamps null: false
    end
  end
end
