class UserSubscription < ApplicationRecord
  belongs_to :user, dependent: :destroy
end
