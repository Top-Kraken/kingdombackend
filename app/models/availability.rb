class Availability < ApplicationRecord
  belongs_to :user

  validates :start_time, :end_time, :day_of_week, presence: true

  validate :check_time_conflicting
 
  # Checking new availability time conflicting with existing availability time
  def check_time_conflicting
    stime = start_time.strftime('%r')
    etime = end_time.strftime('%r')
    wday = day_of_week
    # Validating - Valid start and end time
    errors.add('Invalid', 'end time.') if valid_start_time

    # Validating - Conflicts with existing time
    conflicting_times = select_conflicting_times(stime, etime, wday)
    errors.add('Time conflicting', 'with existing time.') if conflicting_times.present?
  end

  def valid_start_time
    start_time >= end_time
  end

  def select_conflicting_times(stime, etime, wday)
    # rubocop:disable Layout/LineLength
    user.availabilities.where('day_of_week = ? AND ((start_time::time <= ? AND end_time::time >= ?) OR (start_time::time <= ? AND end_time::time >= ?) OR (start_time::time > ? AND end_time::time < ?))', wday, stime, stime, etime, etime, stime, etime)
    # rubocop:enable Layout/LineLength
  end

  def service_detail
    "#{start_time.strftime('%m/%d %I:%M %P')} - #{
      end_time.strftime('%I:%M %P')} with #{member.user.full_name}"
  end

  def self.float_to_time
    sec = ((0.5 || 1) * 3600).to_i
    min, sec = sec.divmod(60)
    hour, min = min.divmod(60)
    [hour, min, sec]
  end

  def self.inbetween_data(availabilities)
    data = []
    add_time = float_to_time
    (Date.tomorrow..Date.today + 4.day).each do |day|
      availabilities.where(day_of_week: day.strftime('%A')).each do |a|
        future_dates = a.collect_future_date_times
        stime = a.start_time
        (1..a.time_difference).each do |_time|
          next unless stime < a.end_time

          etime = stime + add_time[0].hours + add_time[1].minutes + add_time[2].seconds
          if etime <= a.end_time
            cdate = "#{day.strftime('%D')} #{stime.strftime('%r')} #{etime.strftime('%r')}"
            if future_dates.include?(cdate.to_s)
              future_dates -= [cdate.to_s]
            else
              data << [a.format_time(day, stime, etime), a.select_data(stime, etime, day)]
            end
          end
          stime = etime
        end
      end
    end
    data
  end

  def select_data(stime, etime, day)
    "#{id}^#^#{stime.strftime('%I:%M %P')}^#^#{etime.strftime('%I:%M %P')}^#^#{day.strftime('%Y-%m-%d')}"
  end

  def format_time(day, stime, etime)
    "#{day.strftime('%m/%d')} #{stime.strftime('%I:%M %P')} - #{
      etime.strftime('%I:%M %P')} with #{user.full_name}"
  end

  def time_difference
    ((end_time - start_time).hours / 3600).round
  end

  def week_day_format
    Date::DAYNAMES[day_of_week].to_date
  end

  def future_appointments
    user.appointments.where('start_time > ?', Time.now.end_of_day)
  end

  def collect_future_date_times
    future_appointments.map { |m| m.future_formatting_date }
  end

  def duration
    "#{day_of_week} #{start_time.strftime('%l:%M %P')} - #{end_time.strftime('%l:%M %P')}"
  end
end
