class CreateAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.references :user
      t.references :event

      t.timestamps null: false
    end
    add_index :attendees, [:user_id, :event_id], unique: true
  end
end
