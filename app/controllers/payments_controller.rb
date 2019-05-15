class PaymentsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def stripe
        payment_id = params[:data][:object][:payment_intent]
        payment = Stripe::PaymentIntent.retrieve(payment_id)
        user_id = payment.metadata.user_id
        render json: ""
    end

    def success
        current_user.stripe_payment = true
        current_user.save

        # Redirecting user to update profile if they haven't completed it
        # Else, redirects to search page if they're donating for a 2nd+ time
        if current_user.profile_complete != true
            @redirect = "2;url=/users/new"
        else
            @redirect = "2;url=/users"
        end
    end
end