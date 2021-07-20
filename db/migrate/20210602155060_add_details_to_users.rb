# frozen_string_literal: true

class AddDetailsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :status, :integer, default: 0
  end
end
