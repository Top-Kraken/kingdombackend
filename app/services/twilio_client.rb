# frozen_string_literal: true

class TwilioClient # rubocop:todo Style/Documentation
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new account_sid, auth_token
  end

  def send_text(user, message)
    client.api.account.messages.create(
      to: user,
      from: phone_number,
      body: message,
    )
  end

  def send_lead(lead, message, file)
    client.api.account.messages.create(
      to: lead.phone_number,
      from: lead.user.twilio_number,
      body: message,
      media_url: [file]
    )
  end
  
  def user_sms_to_lead(lead, message)
    client.api.account.messages.create(
      to: lead.phone_number,
      from: lead.user.twilio_number,
      body: message
    )
  end

  # Method to get an twilio and give it to a user, you need to add the migration and add it to user, check all of the options https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource
  # You have to save the phone_number from incoming_phone, is what you need to send messages for this number, credential stil the same because the new numner is a instance of our main account
  def generate_account
    toll_free = @client.available_phone_numbers('US').toll_free.list(limit: 1)

    toll_free.each do |record|
      
      incoming_phone_number = @client.incoming_phone_numbers.create(phone_number: record.phone_number)

      puts incoming_phone_number.sid
    end

 
  end

  def incoming_phone_numbers
    # get the twilio incoming phone number list
    @client.incoming_phone_numbers
  end

  private

  def account_sid
    Rails.application.credentials[Rails.env.to_sym][:twilio][:account_sid]
  end

  def auth_token
    Rails.application.credentials[Rails.env.to_sym][:twilio][:auth_token]
  end

  def phone_number
    Rails.application.credentials[Rails.env.to_sym][:twilio][:phone_number]
  end
end
