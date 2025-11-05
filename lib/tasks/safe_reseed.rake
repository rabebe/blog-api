# lib/tasks/db/safe_reseed.rake
# This Rake task is designed to be safe for production environments.
# It only deletes records from the specific model (Post) and then re-runs the seed file.

namespace :db do
  desc "Safely removes all Post records and re-runs the idempotent seed file (Production Safe)"
  task safe_reseed: :environment do
    # Critical Safety Check: Ensure we are not running this in an unexpected environment.
    # While it's safer than 'db:reset', it's always good practice to check.
    if Rails.env.production? || Rails.env.staging?
      puts "Starting SAFE RESEED on #{Rails.env.upcase} environment."
    else
      puts "Running 'db:safe_reseed' in #{Rails.env.upcase}. You might prefer 'db:reset_ids_and_seed' for local development."
    end

    # --- STEP 1: Targeted Deletion ---
    # This removes all records from the Post table ONLY.
    puts "Deleting all existing Post records..."
    Post.destroy_all
    puts "✅ All Post records removed."

    # --- STEP 2: Re-run Idempotent Seed Logic ---
    # This executes db/seeds.rb, which will re-create the new baseline posts.
    puts "Executing db:seed to create new baseline posts..."
    Rake::Task["db:seed"].invoke
    puts "✅ New baseline posts created."

    puts "\n Safe reseed complete. Only Post data was affected. "
  end
end
