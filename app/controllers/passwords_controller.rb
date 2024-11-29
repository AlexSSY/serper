class PasswordsController < ApplicationController
  before_action :authenticate_user!

  def change
    current_user.update! password_change_params
    head :no_content
  end

  private

  def password_change_params
    params.permit(:password, :password_challenge, :password_confirmation).with_defaults(password_challenge: "", password_confirmation: "")
  end
end
