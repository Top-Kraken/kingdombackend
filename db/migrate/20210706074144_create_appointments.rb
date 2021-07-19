class CreateAppointments < ActiveRecord::Migration[6.1]
  def change
    create_table :appointments do |t|
      t.integer :user_id
      t.integer :lead_id
      t.integer :assigned_to_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :progress

      t.timestamps
    end
  end
end
