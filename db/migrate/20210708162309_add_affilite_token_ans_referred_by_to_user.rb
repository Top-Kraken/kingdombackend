class AddAffiliteTokenAnsReferredByToUser < ActiveRecord::Migration[6.1]
  def change
  	add_column :users, :affiliate_token, :string
  	add_column :users, :referred_by_id, :integer
  end
end
