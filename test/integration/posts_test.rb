require "test_helper"

class PostAuthorizationTest < ActionDispatch::IntegrationTest
  # --- Setup: Create Admin User and a Post for testing ---
  def setup
    # Clean slate
    User.delete_all
    Post.delete_all

    # CRITICAL: Create the single admin user for the site
    @admin = User.create!(
      username: "authoruser",
      email: ENV.fetch("ADMIN_EMAIL"),
      password: ENV.fetch("ADMIN_PASSWORD"),
      password_confirmation: ENV.fetch("ADMIN_PASSWORD"),
      is_admin: true # Assuming your User model has this attribute, essential for authorize_admin
    )

    @test_post = Post.create!(
      title: "Test Post",
      body: "This is a test body content.",
      user: @admin
    )
  end

  # Helper method to parse JSON response body
  def json_response
    JSON.parse(response.body)
  end

  def admin_auth_headers
    post "/login", params: { email: @admin.email, password: @admin.password }, as: :json
    token = json_response["token"]

    # Return the headers hash expected by your ApplicationController
    { "Authorization" => "Bearer #{token}" }
  end

  # --- Public access tests (Read-Only) ---

  test "public can view posts" do
    get "/posts"
    assert_response :ok
  end

  # --- Unauthorized access tests (Must be blocked) ---

  test "unauthorized user cannot create post" do
    assert_no_difference("Post.count") do
      # No headers passed
      post "/posts", params: { post: { title: "New Post", body: "Content"  } }, as: :json
    end
    assert_response :forbidden
  end

  test "unauthorized user cannot update post" do
    # No headers passed
    patch "/posts/#{@test_post.id}", params: { post: { title: "Updated Title" } }, as: :json
    assert_response :forbidden

    assert_equal "Test Post", @test_post.reload.title
  end

  # --- Authorized access tests (Must succeed) ---

  test "authorized admin can create post" do
    # 1. Get the guaranteed valid headers
    auth_headers = admin_auth_headers

    assert_difference("Post.count", 1) do
      post "/posts",
           params: { post: { title: "New Admin Post", body: "New post content.", user_id: @admin.id } },
           headers: auth_headers, # PASS THE HEADERS
           as: :json
    end
    assert_response :created
  end

  test "authorized admin can update post" do
    # 1. Get the guaranteed valid headers
    auth_headers = admin_auth_headers

    patch "/posts/#{@test_post.id}",
          params: { post: { title: "Updated Title by Admin" } },
          headers: auth_headers, # PASS THE HEADERS
          as: :json
    assert_response :ok

    assert_equal "Updated Title by Admin", @test_post.reload.title
  end
end
