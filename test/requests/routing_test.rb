require "test_helper"

class RoutingTest < ActionDispatch::IntegrationTest
  test "should return 404 for unmatched routes" do
    get "/nonexistent_route"
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "invalid route", json_response["msg"]
  end
end
