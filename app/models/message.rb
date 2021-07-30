class Message < ApplicationRecord
    belongs_to :user
    belongs_to :lead
end