class Demo < ApplicationRecord
  belongs_to :user
  belongs_to :lead

  scope :month, lambda { |month|
    where(start_datetime: month.beginning_of_month.beginning_of_week..month.end_of_month.end_of_week)
  }
  scope :next_four_days, lambda { |datetime|
    where(start_datetime: datetime.beginning_of_day..(datetime + 3.days).end_of_day)
      .group_by(&:start_datetime)
  }

  def duration
    "#{start_datetime.strftime('%l:%M %P')} - #{end_time.strftime('%l:%M %P')}"
  end

  def end_time
    start_datetime + 30.minutes
  end
end
