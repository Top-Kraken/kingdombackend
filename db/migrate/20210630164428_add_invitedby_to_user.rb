class AddInvitedbyToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :invited_by, :string
  end
end
