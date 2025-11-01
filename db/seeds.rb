require 'time'

# 1. Define Secure Admin Credentials
# The production application MUST set ADMIN_EMAIL environment variable.
admin_email = ENV.fetch("ADMIN_EMAIL") { raise "ADMIN_EMAIL environment variable is not set." }
admin_password = ENV.fetch("ADMIN_PASSWORD") { raise "ADMIN_EMAIL environment variable is not set." }

# 2. Ensure Idempotency: Clear existing posts and users
puts "Clearing existing data..."
Post.destroy_all
User.destroy_all

# 3. Create the Admin User
puts "Creating Admin User: #{admin_email}"
admin = User.create!(
  email: admin_email,
  password: admin_password,
  password_confirmation: admin_password,
  username: "Admin Author",
  is_admin: true
)
puts "Admin User ID: #{admin.id}"


# 4. Create Sample Blog Posts
puts "Creating sample blog posts and linking them to the Admin User..."

Post.create!(
  title: "First Steps with a Rails API",
  body: "The journey begins by using the --api flag to ensure Rails is lightweight. We set up CORS immediately to allow our separate frontend website to access the data. This decoupled architecture is fast and scalable.",
  user_id: admin.id, # Link post to the admin user
  published_at: Time.current
)

Post.create!(
  title: "Why Decouple Your Blog?",
  body: "Decoupling (using an API for the backend and a separate framework for the frontend) lets you choose the best tool for each job. Rails handles the database and security, while a JavaScript framework like React or Vue can handle a fast, dynamic user interface.",
  user_id: admin.id,
  published_at: 1.day.ago
)

Post.create!(
  title: "Testing Your API Endpoints",
  body: "Once the scaffold is complete and migrations are run, you should test the endpoints. You can use tools like Postman or a simple browser extension to hit '/posts' and verify the JSON output. This ensures your data is accessible before writing any frontend code.",
  user_id: admin.id,
  published_at: 2.days.ago
)

puts "Seeding complete. Created #{User.count} user(s) and #{Post.count} post(s)."
