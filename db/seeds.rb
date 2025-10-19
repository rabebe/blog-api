# db/seeds.rb

# 1. Ensure idempotency: Clear existing posts so running db:seed multiple times doesn't duplicate data.
puts "Clearing existing posts..."
Post.destroy_all

# 2. Create 3 sample blog posts
puts "Creating sample blog posts..."

Post.create!(
  title: "First Steps with a Rails API",
  body: "The journey begins by using the --api flag to ensure Rails is lightweight. We set up CORS immediately to allow our separate frontend website to access the data. This decoupled architecture is fast and scalable.",
  author: "Your Name",
  published_at: Time.current
)

Post.create!(
  title: "Why Decouple Your Blog?",
  body: "Decoupling (using an API for the backend and a separate framework for the frontend) lets you choose the best tool for each job. Rails handles the database and security, while a JavaScript framework like React or Vue can handle a fast, dynamic user interface.",
  author: "Your Name",
  published_at: 1.day.ago
)

Post.create!(
  title: "Testing Your API Endpoints",
  body: "Once the scaffold is complete and migrations are run, you should test the endpoints. You can use tools like Postman or a simple browser extension to hit '/posts' and verify the JSON output. This ensures your data is accessible before writing any frontend code.",
  author: "Your Name",
  published_at: 2.days.ago
)

puts "Seeding complete. Created #{Post.count} posts."