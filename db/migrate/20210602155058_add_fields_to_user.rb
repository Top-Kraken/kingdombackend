# frozen_string_literal: true

class AddFieldsToUser < ActiveRecord::Migration[6.1] # rubocop:todo Style/Documentation
  def change
    add_column :users, :full_name, :string
    add_column :users, :phone_number, :string
  end
end
