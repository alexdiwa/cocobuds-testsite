class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  # Redirecting after user has signed up with devise
  def after_sign_up_path_for(resource)
    "/pages/donate"
  end

  def after_inactive_sign_up_path_for(resource)
    "/pages/donate"
  end

end
