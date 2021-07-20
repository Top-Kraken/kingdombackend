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
Subscription.find_or_create_by(price: 194.99, second_price: 174.99, name: "second_plan", detail: "$194.99 for the first month and then $174.99 every month after")
Subscription.find_or_create_by(price: 244.99, second_price: 224.99, name: "second_plan", detail: "$244.99 for the first month and then $ 224.99 every month after")
Subscription.find_or_create_by(price: 564.99, second_price: 544.99, name: "second_plan", detail: "$564.99 for the first month and then $ 5444.99 every month after")

user = User.find_by(phone_number: '+12025550185')
unless user
  user = User.create phone_number: '+12025550185', password: '123456', password_confirmation: '123456', full_name: 'Jack Doe', status: 'active'
  UserSubscription.find_or_create_by(subscription_id: '1', user_id: user.id, stripe_subscription: '123', status: true)
  
  lead = user.leads.create first_name: 'John', phone_number: '+12025550186',
                           heat: 0, stage: 0,
                           facebook: 'https://www.facebook.com'
  
  [*DateTime.now..(DateTime.now + 2.months)].each do |datetime|
    start_datetime = [datetime + 10.minutes, datetime + 20.minutes, datetime + 30.minutes]
    Demo.create(start_datetime: start_datetime.sample, lead: lead, user: user)
  end
end
