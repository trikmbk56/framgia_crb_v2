class AddEmailRequireToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_require, :boolean, default: false
  end
end
