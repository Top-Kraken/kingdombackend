# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :user_authenticated?
  # The code is a copy from Flow
  def index
    @subscription = Subscription.first
    @amount = 19_599
    @unit_amount = 17_599
  end

  def create
    customer = Stripe::Customer.create({
                                         email: params[:stripeEmail],
                                         source: params[:stripeToken]
                                       })
    Stripe::Charge.create({
                            customer: customer.id,
                            amount: 2_000,
                            description: 'Onboarding with Kingdom',
                            currency: 'usd'
                          })

    product = Stripe::Product.create({ name: 'Domain Subscription' })

    price = Stripe::Price.create({
                                   unit_amount: 17_599,
                                   currency: 'usd',
                                   recurring: { interval: 'month' },
                                   product: product.id
                                 })

    Stripe::Subscription.create({
                                  customer: customer.id,
                                  items: [
                                    { price: price.id }
                                  ]
                                })

    # It works and redirect to the same page
    redirect_to request.referrer
  rescue Stripe::CardError => e
    flash[:error] = e.message
  end

  def destroy
    Stripe.api_key = ENV['SECRET_KEY']

    Stripe::Customer.delete(params[:id])
  end
end
