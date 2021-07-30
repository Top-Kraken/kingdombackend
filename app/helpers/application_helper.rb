module ApplicationHelper
  include Pagy::Frontend
  def date_translation(date)
    date = date.to_date unless date.kind_of? Date

    case date
    when Date.today
      'Today'
    when Date.today.next_day
      'Tomorrow'
    else
      date.strftime('%A, %B %e')
    end
  end

  def select_time_drop_down_values
    select_time = []
    ('2020-01-01'.to_datetime.to_i..'2020-01-02'.to_datetime.to_i).step(30.minutes) do |date|
      select_time <<
        (
          Time
            .at(date)
            .strftime(
              '%l:%M' \
              ' %p'
            )
        ).to_s
    end
    return select_time
  end

  # Return Time Range Array
  def time_range
    range_time = []
    (1..12).each do |n|
      time = n == 1 ? 12 : n - 1
      range_time << "#{time}:00 am"
      range_time << "#{time}:30 am"
    end
    (1..12).each do |n|
      time = n == 1 ? 12 : n - 1
      range_time << "#{time}:00 pm"
      range_time << "#{time}:30 pm"
    end
    range_time
  end
end
