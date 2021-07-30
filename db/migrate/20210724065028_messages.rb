class Messages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lead, null: false, foreign_key: true
      t.integer :type
      t.integer :status

      t.timestamps
    end
  end
end
