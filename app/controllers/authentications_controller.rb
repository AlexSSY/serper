class AuthenticationsController < ApplicationController
  def registration
    @user = User.create! registration_params
  end

  def login
    @user = User.authenticate_by login_params
    render_error "invalid credentials" unless @user.present?
  end

  private

  def registration_params
    params.permit(:email, :password, :password_confirmation).with_defaults(password_confirmation: " ")
  end

  def login_params
    params.permit(:email, :password).with_defaults(email: "", password: "")
  end
end
