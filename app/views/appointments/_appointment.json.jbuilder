json.extract! appointment, :id, :user_id, :lead_id, :assigned_to_id, :start_time, :end_time, :progress, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)
