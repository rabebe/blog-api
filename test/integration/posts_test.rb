require "test_helper"

class PostAuthorizationTest < ActionDispatch::IntegrationTest
  attr_reader :admin_password_text, :admin_email, :admin

  def setup
    User.delete_all
    Post.delete_all

    # Admin credentials
    @admin_email = ENV["ADMIN_EMAIL"].presence || "admin@test.dev"
    @admin_password_text = ENV["ADMIN_PASSWORD"].presence || "pAssWord12345"

    @admin = User.create!(
      username: "authoruser",
      email: @admin_email,
      password: @admin_password_text,
      password_confirmation: @admin_password_text,
      role: 1
    )

    @admin.reload

    @test_post = Post.create!(
      title: "Test Post",
      body: "This is a test body content.",
      user: @admin
    )
  end

  def json_response
    JSON.parse(response.body)
  end

  def admin_auth_headers
    post "/login", params: { email: @admin.email, password: @admin_password_text }, as: :json
    token = json_response["token"]

    if response.status != 200 || token.blank?
      puts "--- ADMIN LOGIN FAILED ---"
      puts response.body
      return {}
    end

    { "Authorization" => "Bearer #{token}" }
  end

  # --- Public access tests ---
  test "public can view posts" do
    get "/posts"
    assert_response :ok
  end

  # --- Unauthorized access tests ---
  test "unauthorized user cannot create post" do
    assert_no_difference("Post.count") do
      post "/posts", params: { post: { title: "New Post", body: "Content" } }, as: :json
    end
    # Update to match your API behavior: 401 Unauthorized
    assert_response :unauthorized
    assert_equal "Authentication required", json_response["error"]
  end

  test "unauthorized user cannot update post" do
    patch "/posts/#{@test_post.id}", params: { post: { title: "Updated Title" } }, as: :json
    assert_response :unauthorized
    assert_equal "Authentication required", json_response["error"]
    assert_equal "Test Post", @test_post.reload.title
  end

  # --- Authorized access tests ---
  test "authorized admin can create post" do
    auth_headers = admin_auth_headers
    assert_difference("Post.count", 1) do
      post "/posts",
           params: { post: { title: "New Admin Post", body: "New post content.", user_id: @admin.id } },
           headers: auth_headers,
           as: :json
    end
    assert_response :created
  end

  test "authorized admin can update post" do
    auth_headers = admin_auth_headers
    patch "/posts/#{@test_post.id}",
          params: { post: { title: "Updated Title by Admin" } },
          headers: auth_headers,
          as: :json
    assert_response :ok
    assert_equal "Updated Title by Admin", @test_post.reload.title
  end
end
