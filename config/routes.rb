Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope defaults: { format: :json } do
    post "registration", to: "authentications#registration", as: :registration
    post "login", to: "authentications#login", as: :login
    resource :profile, only: :show
    post "password/change", to: "passwords#change", as: :password_change
  end

  # Catch-all route for unmatched paths
  match "*unmatched", to: "application#route_not_found", via: :all
end
