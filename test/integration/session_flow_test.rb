require "test_helper"

class SessionFlowTest < ActionDispatch::IntegrationTest
  def setup
    User.delete_all
    # Create a non-admin user for general session flow testing
    @user = User.create!(
      username: "testuser",
      email: "test@blog.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  # Helper method to parse JSON response body
  def json_response
    JSON.parse(response.body)
  end

  # Helper method to log in and get headers for a given user
  def user_auth_headers(user)
    post "/login", params: { email: user.email, password: "password123" }, as: :json
    token = json_response["token"]
    { "Authorization" => "Bearer #{token}" }
  end

  test "successful login returns JWT token and username" do
    post "/login", params: { email: @user.email, password: "password123" }, as: :json
    assert_response :ok

    token = json_response["token"]
    assert_not_nil token, "Login response missing token"

    assert_equal @user.username, json_response["username"]
  end

  test "login fails with invalid credentials" do
    post "/login", params: { email: @user.email, password: "wrongpassword" }, as: :json
    assert_response :unauthorized
    assert_equal "Invalid email or password", json_response["error"]
  end

  test "logout runs 204 no content" do
    # 1. Log in to get fresh headers locally
    auth_headers = user_auth_headers(@user)

    # 2. Use the token to access the protected logout route
    delete "/logout", headers: auth_headers
    assert_response :no_content # Expect 204 No Content
  end
end
