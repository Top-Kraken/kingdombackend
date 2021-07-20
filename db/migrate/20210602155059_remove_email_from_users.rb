# frozen_string_literal: true

class RemoveEmailFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, name: 'index_users_on_email'
    remove_column :users, :email
  end
end
