class CreateRepeatOns < ActiveRecord::Migration
  def change
    create_table :repeat_ons do |t|
      t.integer :repeat_on
      t.references :event
      t.timestamps null: false
    end
  end
end
