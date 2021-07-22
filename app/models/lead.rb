# frozen_string_literal: true

class Lead < ApplicationRecord
  belongs_to :user
  has_many :appointments, dependent: :destroy
  has_many :demos, dependent: :destroy
  enum stage: { prospecting: 0, contacted: 1, demo: 2, followup: 3, closing: 4 }
  enum heat: { cold: 0, warm: 1, hot: 2 }

  validates :first_name, presence: true
  validates :phone_number, uniqueness: true,
                           presence: true
  #  This validation for US numbers
  validates :phone_number,
            format: { with: /\A(?:\+?\d{1,3}\s*-?)?\(?(?:\d{3})?\)?[- ]?\d{3}[- ]?\d{4}\z/,
                      message: 'Invalid phone number' }

  scope :search, ->(query) { where('first_name ILIKE ? OR last_name ILIKE ?', "%#{query}%", "%#{query}%") }
  scope :search_stage, ->(query) { where(stage: query) }

  after_create :after_lead_create

  require 'csv'

  # user should be deleted after adding the functionality for user to sign-in
  def self.import(user, path)
    CSV.foreach(path, headers: true,
                      skip_blanks: true,
                      skip_lines: /^(?:,\s*)+$/) do |row|
      new_hash = {}
      row.to_hash.each_pair do |k, v|
        new_hash.merge!({ k.downcase => v })
        puts k
        puts v
        next if new_hash['phone_number'].nil?
      end
      user.leads.create(new_hash)

      p new_hash
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.last_created
    where('created_at >= ?', 10.minutes.ago)
  end

  def after_lead_create
    self.update(stage: "prospecting")
    send_satge_related_notification
  end

  def send_satge_related_notification
    message = ""
    message2 = ""
    is_send = false
    case stage
    when "prospecting"
      message = get_send_message(prospecting_message_send_at)
    when "contacted"
      message = get_send_message(contacted_message_send_at)
    when "demo"
      message = get_send_message(demo_message_send_at)
      message2 = get_send_message(followup_message_send_at, 'demo_msg2')
    when "followup"
      message = get_send_message(followup_message_send_at)
    when "closing"
      message = get_send_message(closing_message_send_at)
    end
    p "send msg to lead #{self.stage}"
    p message
    p message2
    is_send = send_text(user.phone_number, message) if message.present?
    send_text(user.phone_number, message2) if message2.present?
    update_send_at if is_send.present?
  end

  def send_text(phone_number,message)
    begin
      TwilioClient.new.user_sms_to_lead(self, message)
      return true
    rescue Exception => e
      return true
    end
  end

  def send_lead(phone_number,message, filePath)
    begin
      puts "BBB"*25
      TwilioClient.new.send_lead(self, message, filePath)
      puts "CCC"*25
      return true
    rescue Exception => e
      return true
    end
  end

  def send_demo_nofication
    send_text(phone_number,"Demo created successfuly, you will be notified with Meeting link")
  end

  def send_document_nofication(filePath)
    puts "AAA"*25
    send_lead(phone_number,"Document will be shared later.", filePath)
  end

  def update_send_at
    case stage
    when "prospecting"
      self.update_attribute(:prospecting_message_send_at, Time.now)
    when "contacted"
      self.update_attribute(:contacted_message_send_at, Time.now)
    when "demo"
      self.update_attribute(:demo_message_send_at, Time.now)
    when "followup"
      self.update_attribute(:followup_message_send_at, Time.now)
    when "closing"
      self.update_attribute(:closing_message_send_at, Time.now)
    end
  end

  def get_send_message(is_send_at, demo_msg=nil)
    return if is_send_at.present?
    if stage == "prospecting"
      if added_from == "web_form"
        msg = " Look at these modern ways to make that much needed Passive Income #{get_stage_url} " + "Talk soon, " + "#{user.try(:full_name)}"
      else
        msg = "Hey #{first_name}, " + " What would you do if you woke up and didn’t have anything but the clothes on your back and the phone in your hand? That’s a tough one huh? Clink the link #{get_stage_url} and we’ll show how you can go from broke to whatever you can think of. " + "#{user.try(:full_name)}"
      end
    elsif stage == "contacted"
      msg = "Hey #{first_name}, " + " It doesn’t matter what road you are on right now. You can always change directions and start making more money. Go to the link  #{get_stage_url}  to find out how to invest in yourself." + "It’s your time to win, " + "#{user.try(:full_name)}"
    elsif stage == "demo"
      if demo_msg == "demo_msg2"
        # msg = msg + " your meeting is coming up at #{demo_scheduled_time} and we are going to discuss at Zoom #{user.zoom_link}"
        msg = "Hi #{first_name}, " + " Here’s the link for your demo #{user.zoom_link}. You’re going to love to hear about this! " + "#{user.try(:full_name)}"
      else
        msg = "Yayyy #{first_name}, " + "You booked a demo! You’re headed in the right direction. If they can do it so can you! See who went from Rags to Riches at this link #{get_stage_url}. " + "#{user.try(:full_name)}"
      end
    elsif stage == "followup"
     msg = "Hey #{first_name}, " + " Do you know the difference between highly successful and non successful ppl?  Successful ppl don’t allow their fears to stop them from making smart decisions. The smartest decision is here #{get_stage_url} " + "Don’t let this opportunity slip through your fingers. " + "#{user.try(:full_name)}"
    elsif stage == "closing"
      msg = "Yaass #{first_name}, " + " Can’t you just feel the good vibes and energy going through your body? Watch the video we made just to celebrate you #{get_stage_url} " + "#{user.try(:full_name)}"
    end
    # "#{stage.to_s.titleize}: #{get_stage_url} #{zoom_link if stage == 'demo'}" unless is_send_at.present?
    return msg
  end

  def demo_scheduled_time
    schedule = appointments.last
    if schedule
      "#{schedule.start_time.strftime("%F %I:%M %p")} - #{schedule.end_time.strftime("%F %I:%M %p")}"
    end
  end

  def zoom_link
    "\nZoom Link: #{user.zoom_link}"
  end

  def get_stage_url
    state_name_in_url = stage
    if stage === "prospecting"
      state_name_in_url = "prospect"
    elsif stage === "closing"
      state_name_in_url = "closed"
    end
    "#{ENV['ROOT_URL']}/users/#{user.try(:id)}/#{state_name_in_url}/#{phone_number}"
  end

  def self.check_pending_prospecting
    pipeline_waiting_hour = Rails.application.credentials.pipeline_waiting_hour
    limit_hours = Rails.env == "production" ? pipeline_waiting_hour.hours : 12.minutes
    prospectings = Lead.search_stage("prospecting").where("prospecting_message_send_at < ?",(Time.now - limit_hours).in_time_zone('UTC'))
    p "Checking Leads - Prospect - at #{Time.now}"
    p "Leads - Prospect - count: #{prospectings.size}"
    prospectings.each do |prospecting|
      unless prospecting.appointments.count.positive?
        prospecting.update_attribute(:stage, 1)
        prospecting.send_satge_related_notification
      end
    end
  end

  def self.check_pending_demo
    pipeline_waiting_hour = Rails.application.credentials.pipeline_waiting_hour
    limit_hours = Rails.env == "production" ? pipeline_waiting_hour.hours : 12.minutes
    demos = Lead.search_stage("demo").where("demo_message_send_at < ?",(Time.now - limit_hours).in_time_zone('UTC'))
    p "Checking Leads - Demo - at #{Time.now}"
    p "Leads - Demo - count: #{demos.size}"
    demos.each do |demo|
      unless demo.is_purchase_subscription.present?
        demo.update_attribute(:stage, 3)
        demo.send_satge_related_notification
      end
    end
  end
end
