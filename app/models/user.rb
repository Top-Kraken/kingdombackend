class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, authentication_keys: [:phone_number]
  validates :phone_number, phone: true, uniqueness: true
  validates :phone_number, format: { with: /\A\+(?:[0-9]●?){6,14}[0-9]\z/,
                                    message: 'Invalid phone format' }
  has_one :user_subscription, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_many :demos, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :appointments, dependent: :destroy

   enum status: { inactive: 0, active: 1 }
   validate :valid_create_account, on: :create

   after_create :update_affilite_token

   def update_affilite_token
      self.update_attribute(:affiliate_token, "#{self.id}#{SecureRandom.urlsafe_base64}")
      return unless referred_by
      lead = referred_by.leads.find_by(phone_number: phone_number)
      return unless lead
      lead.update(stage: 4)
      lead.send_satge_related_notification
   end

  def referred_by
    User.find_by(id: referred_by_id)
  end

   def valid_create_account
    phone_numbers = User.incoming_phone_numbers.list.map(&:phone_number)
    available_phone_numbers = phone_numbers - User.user_phone_numbers - ['+18562194371']
    # Check the valuable number are present
    if available_phone_numbers.count.positive?
      # Assign the phone number to account which are in avaliable
      self.twilio_number = available_phone_numbers.first
    else
      errors.add(:twilio_number, 'is not avaliable.')
    end
  end

  def self.user_phone_numbers
    # Collect the existing account's phone
    User.all.collect(&:twilio_number).compact
  end

  def self.incoming_phone_numbers
    # To get the incoming phone numbers for twilio account
    TwilioClient.new.incoming_phone_numbers
  end

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end

  def is_active?
    return status == "active" ? true : false
  end 
end
