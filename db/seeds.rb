# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

##

##
# ##create subscription
Subscription.create!(name: 'Main', price: '195.99', detail: '195.99 for the first month, the 175.99 each month')

user = User.create phone_number: '+12025550185', password: '123456', password_confirmation: '123456', full_name: 'Jack Doe', status: 'active'

UserSubscription.find_or_create_by(subscription_id: '1', user_id: user.id, stripe_subscription: '123', status: true)

lead = user.leads.create first_name: 'John', phone_number: '+12025550186',
                         heat: 0, stage: 0,
                         facebook: 'https://www.facebook.com'

[*DateTime.now..(DateTime.now + 2.months)].each do |datetime|
  start_datetime = [datetime + 10.minutes, datetime + 20.minutes, datetime + 30.minutes]
  Demo.create(start_datetime: start_datetime.sample, lead: lead, user: user)
end
