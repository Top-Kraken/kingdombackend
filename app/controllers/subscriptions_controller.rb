# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :inactive?
  skip_before_action :check_user_subscription

  # The code is a copy from Flow
  def index
    @subscription = Subscription.first
    @amount = 19_599
    @unit_amount = 17_599
  end

  def create
    exp_date = params[:date].split('/');
    card_number = params[:number].gsub("-","");
    token = Stripe::Token.create({
      card: {
        number: card_number,
        exp_month: exp_date[0].to_i,
        exp_year: exp_date[1].to_i,
        cvc: params[:cvc],
      },
    })
    subscription = Subscription.find_by_id(params[:subscription_id])
    if subscription
      customer = Stripe::Customer.create({email: params[:email], source: token.id})
      Stripe::Charge.create({
        customer: customer.id,
        amount: (subscription.price.to_f * 100).to_i,
        description: 'Onboarding with Kingdom',
        currency: 'usd'
      })
      product = Stripe::Product.create({ name: 'Monthly Subscription' })
      price = Stripe::Price.create({
        # unit_amount: 12_499,#(subscription.second_price.to_f * 100).to_i,
        unit_amount_decimal: (subscription.second_price.to_f * 100).to_i,
        currency: 'usd',
        recurring: { interval: 'month' },
        product: product.id
      })
      stripe_subscription = Stripe::Subscription.create({
        customer: customer.id,
        items: [
          { price: price.id }
        ]
      })
      if current_user.user_subscription.nil?
        user_subscription = current_user.build_user_subscription(subscription_id: subscription.id, stripe_subscription: stripe_subscription.id, status: true)
        user_subscription.save
      else
        current_user.user_subscription.update(stripe_subscription: stripe_subscription.id)
      end
      redirect_to add_domain_path
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
  end

  def destroy
    Stripe.api_key = ENV['SECRET_KEY']

    Stripe::Customer.delete(params[:id])
  end


  def add_domain; end

  def search_domain
    @domains = EnomClient.new.search_keywords(params[:registration][:search])
    respond_to do |format|
      format.js
    end
  end

  def select_domain
    user = current_user
    unless user.domain.present?
      domain = EnomClient.new.register_domain(params[:domain], current_user)
      Rails.logger.info '******************* ENOM DOMAIN REGISTER RESPONSE *******************'
      Rails.logger.info domain
      # domain_name = domain.try(:first).dig 'AddBulkDomains', 'Item', 'ItemName'
      current_user.update(domain: params[:domain])
    end
    redirect_to root_path
  end

end
