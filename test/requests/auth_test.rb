require "test_helper"

class AuthTest < ActionDispatch::IntegrationTest
  test "user can register if all params is valid" do
    post "/registration", params: {
      email: "test@mail.com",
      password: "Password123@",
      password_confirmation: "Password123@"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["auth_token"]
  end

  test "user can log in with valid credentials" do
    post "/login", params: {
      email: "existing@user.com",
      password: "Password123@"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "auth_token_for_one", json_response["auth_token"]
  end

  test "user gets correct error when attempt register with empty request body" do
    post "/registration", params: {}

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "record invalid", json_response["msg"]
  end

  test "user can't be authorized with invalid auth_token" do
    get "/profile", headers: {
      "Authorization": "invalid_token"
    }

    assert_response :unauthorized
  end

  test "user can be authorized with valid auth_token" do
    get "/profile", headers: {
      "Authorization": "auth_token_for_one"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "existing@user.com", json_response["email"]
  end

  test "new registered user has unverified email" do
    post "/registration", params: {
      email: "romik@pomik.com",
      password: "Password123@",
      password_confirmation: "Password123@"
    }

    assert_not User.last.is_email_verified
  end

  test "user can't register without password_confirmation" do
    post "/registration", params: {
      email: "newusere@mail.com",
      password: "Password123@"
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "record invalid", json_response["msg"]
  end

  test "banned user can't access protected endpoints" do
    get "/profile", headers: {
      "Authorization": "auth_token_for_two"
    }

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "unauthorized", json_response["msg"]
  end

  test "authorized user can change password" do
    post "/password/change", headers: {
      "Authorization": users(:one).auth_token
    }, params: {
      password: "NewPassword@",
      password_confirmation: "NewPassword@",
      password_challenge: "Password123@"
    }

    assert_response :success
    assert_not_nil User.authenticate_by(email: users(:one).email, password: "NewPassword@")
  end

  test "user can't change password without password_challenge" do
    post "/password/change", headers: {
      "Authorization": users(:one).auth_token
    }, params: {
      password: "NewPassword@",
      password_confirmation: "NewPassword@"
    }

    assert_response :unprocessable_entity
    assert_nil User.authenticate_by(email: users(:one).email, password: "NewPassword@")
  end

  test "user can't change password without password_confirmation" do
    post "/password/change", headers: {
      "Authorization": users(:one).auth_token
    }, params: {
      password: "NewPassword@",
      password_challenge: "Password123@"
    }

    assert_response :unprocessable_entity
    assert_nil User.authenticate_by(email: users(:one).email, password: "NewPassword@")
  end
end
