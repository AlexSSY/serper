class ApplicationController < ActionController::API
rescue_from ActiveRecord::RecordInvalid, with: ->(exception) { render_validation_error exception.record }
rescue_from ActionController::RoutingError, with: :handle_routing_error

  def handle_routing_error
    render_error "invalid route", status: :not_found
  end

  def render_validation_error(record)
    if record.present?
      render_error "record invalid", body: record.errors
    else
      render_error "record invalid"
    end
  end

  def render_unauthorized_error
    render_error "unauthorized", status: :unauthorized
  end


  def render_error(message, body: nil, status: :unprocessable_entity)
    render json: { msg: message, body: body }, status: status
  end

  def route_not_found
    handle_routing_error
  end

  # authentication

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    render_unauthorized_error unless user_signed_in?
  end

  def current_user
    User.find_by auth_token: auth_token, is_active: true if auth_token.present?
  end

  def auth_token
    request.headers["Authorization"]
  end
end
