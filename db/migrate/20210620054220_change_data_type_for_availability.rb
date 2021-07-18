class ChangeDataTypeForAvailability < ActiveRecord::Migration[6.1]
  def up
    change_column :availabilities, :start_time, :time
    change_column :availabilities, :end_time, :time
    change_column :availabilities, :day_of_week, :string
  end

  def down
    change_column :availabilities, :start_time, :datetime
    change_column :availabilities, :end_time, :datetime
    change_column :availabilities, :day_of_week, :integer
  end
end
