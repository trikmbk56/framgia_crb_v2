class CreateNotificationEvents < ActiveRecord::Migration
  def change
    create_table :notification_events do |t|
      t.references :event, index: true, foreign_key: true
      t.references :notification, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
