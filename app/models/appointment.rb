# frozen_string_literal: true

# Appointment model
class Appointment < ApplicationRecord
    include ActionView::Helpers::DateHelper
  
    validates :start_time, :end_time, presence: true
  
    belongs_to :user
    belongs_to :lead
    belongs_to :assigned_to, class_name: 'User', foreign_key: :assigned_to_id
  
    # Scopes
    scope :starts_from, lambda { |start_time, user|
      where(user_id: user.id, start_time: start_time.beginning_of_month.beginning_of_week..start_time.end_of_month.end_of_week)
    }
    scope :of_day, lambda { |datetime, user|
      where(user_id: user.id, start_time: datetime.beginning_of_day..datetime.end_of_day)
        .or(where(user_id: user.id, end_time: datetime.beginning_of_day..datetime.end_of_day))
        .group_by_hour_of_day(series: true, format: '%l:%M %p') { |u| u.start_time }
    }

    scope :month, lambda { |month|
      where(start_time: month.beginning_of_month.beginning_of_week..month.end_of_month.end_of_week)
    }

    scope :next_four_days, lambda { |datetime|
      where(start_time: datetime.beginning_of_day..(datetime + 3.days).end_of_day)
        .group_by(&:start_time)
    }

  
    validate :check_valid_time, on: :create
    enum progress: %i[SCHEDULED OTW START END INVOICE PAID]
    after_create :lead_stage_moved_to_demo

    def lead_stage_moved_to_demo
      lead.update_attribute(:stage, 'demo')
      lead.send_satge_related_notification
    end
  
    # Utility Methods
    def self.employee_only(assigned_to)
      where(assigned_to: assigned_to)
    end
  
    # Instance Methods
    def completes_on_same_day?
      start_time.to_date == end_time.to_date
    end
    
    def availabilities
      user.availabilities
    end

    def duration
      "#{start_time.strftime('%l:%M %P')} - #{end_time.strftime('%l:%M %P')}"
    end

    def end_time
      start_time + 30.minutes
    end
  
    def check_valid_time
      # check validation start and end time's conflict and availables
      appointments = collect_exits_appointments
      if appointments.count.positive?
        if appointments.size == 1 
          if appointments.first.id
            errors.add('Time conflicting', 'with existing time.')
          end
        else
          errors.add('Time conflicting', 'with existing time.')
        end
      else
        select_availabilities = selected_availabilities
        # errors.add('Invalid', 'start and end time.') unless select_availabilities.count.positive?
      end
    end
  
    def collect_exits_appointments
      assigned_to.appointments.where.not(id: id).where('start_time <= ? AND end_time >= ?', start_time, end_time)
    end
  
    def selected_availabilities
      availabilities.where('day_of_week = ? AND (start_time::time <= ? AND end_time::time >= ?)',
                           start_time.strftime('%A'), start_time.strftime('%r'), end_time.strftime('%r'))
    end
  
    def future_formatting_date
      "#{start_time.strftime('%D')} #{start_time.strftime('%r')} #{end_time.strftime('%r')}"
    end
  
    # formats appointment date based on start date
    def time_format_from
      if Time.now < start_time
        "#{distance_of_time_in_words_to_now(start_time)} from now"
      else
        "#{distance_of_time_in_words_to_now(start_time)} ago"
      end
    end
  
    # sends text messages to the admin members of an account when progress status is updated
    def send_text_to_members(user)
      message = 'appointment hasa been scheduled'
      assignee = assigned_to.full_name
      service_name = service.name
      case progress
      when 'SCHEDULED'
        message = "appointment has been scheduled for #{service_name}"
      when 'OTW'
        message = "#{assignee} is on the way for the #{service_name} service"
      when 'START'
        message = "#{assignee} has started the appointment for the #{service_name} service"
      when 'END'
        message = "#{assignee} has completed the #{service_name} service"
      when 'INVOICE'
        message = "an invoice has been created for #{assignee} for the #{service_name} service"
      when 'PAID'
        message = "a payment has been made to #{assignee} for the #{service_name} service"
      else
        message
      end
  
        TwilioClient.new.send_text(user.phone_number, message)
    end
  end
  