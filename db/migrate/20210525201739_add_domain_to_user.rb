class AddDomainToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :domain, :string
  end
end
