class AddZoomToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :zoom_link, :string
  end
end
