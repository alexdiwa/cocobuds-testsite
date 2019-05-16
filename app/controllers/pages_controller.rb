class PagesController < ApplicationController
  def donate 
    @name = "#{current_user.first_name} #{current_user.last_name}"
    stripe_session = Stripe::Checkout::Session.create(
    customer_email: current_user.email,
    payment_method_types: ['card'],
    line_items: [{
    name: @name,
    description: "Thanks for donating!",
    amount: 100,
    currency: 'aud',
    quantity: 1,
    }],
    payment_intent_data: {
        metadata: {
          user_id: current_user.id
        }
      },
        success_url: 'https://cocobuds-testsite.herokuapp.com/payments/success',
        cancel_url: 'https://cocobuds-testsite.herokuapp.com/cancel',
    )
    @stripe_session_id = stripe_session.id
    
    render template: "pages/donate"
  end

  def underconstruction
  end
end