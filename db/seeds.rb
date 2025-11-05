require 'time'

# ==============================================================================
# 1. Configuration and Idempotency Strategy
# This file is SAFE to run multiple times without deleting existing data.
# It uses find_or_create_by! to ensure records are only created if they don't exist.
# ==============================================================================

# Define Secure Admin Credentials (Fetching from ENV for production safety)
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@default.dev")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

puts "Starting production-safe seeding process..."

# NO DESTRUCTIVE COMMANDS: The lines for TRUNCATE have been removed.

# ==============================================================================
# 2. Find or Create the Admin User (Idempotent)
# ==============================================================================

puts "Finding or creating Admin User: #{admin_email}"

# Use find_or_create_by! to check if a user with this email already exists
admin = User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.username = "Admin Author"
  user.is_admin = true
end
puts "Admin User ID: #{admin.id}"


# ==============================================================================
# 3. Create Detailed Blog Posts
# The posts use double line breaks (\n\n) for paragraphs and '#' for subtitles,
# which aligns with the rendering logic in the Next.js frontend.
#
# NOTE: Using %Q(...) delimiters to comply with Rubocop Style/PercentLiteralDelimiters.
# ==============================================================================

puts "Creating 3 detailed blog posts and linking them to the Admin User..."

# --- POST 1: AI Summarization System ---
Post.create!(
  title: "Teaching My AI to Think Twice: What I Learned Building a Self-Correcting Summarization System",
  body: %Q(
When I started building my self-correcting summarization workflow, I thought I was just making a better summarizer. What I ended up building was a system that constantly challenges itself — and in the process, taught me a lot about my own approach to engineering.

The project uses LangGraph to create a looping workflow where a **Summarizer** writes a draft, a **Judge** critiques it, and a **Refiner** revises it. It keeps going until the Judge approves the final summary. I deployed the app using Flask and Render, so anyone can send in text and watch the AI go through its iterative process.

Here’s what stood out to me from the experience.

#What I Enjoyed: Building Systems That Think Like People

What I enjoyed most was designing something that feels alive. The first time I watched the agents run in sequence — writing, critiquing, refining — I realized I wasn’t just chaining API calls; I was orchestrating behavior.

I liked how LangGraph forces you to think in terms of **state transitions**. Each node is responsible for producing a piece of state and deciding what comes next. It’s not unlike building a small operating system — there’s logic, memory, and control flow.

I also really enjoyed working with **Pydantic** to enforce structure in the agents’ outputs. Having the model return a typed `JudgeResult` with `should_refine: bool` and `feedback: str` made everything predictable. It turned the LLM from a black box into something closer to a reliable collaborator.

There’s something satisfying about that — not just calling an API, but designing an interface between humans, models, and machines.

#What I Struggled With: Keeping State and Structure Aligned

My biggest struggle was managing state across the workflow. In LangGraph, each node must explicitly return the keys you want to keep. I initially lost data because one of my nodes **overwrote the shared state** instead of extending it. The result? My final node would output "summary not found", even though everything had worked moments before.

It was a painful but valuable reminder: data doesn’t persist magically just because your logic feels correct. Every part of the system needs to deliberately hand off its results to the next.

The other tough part was getting consistent structured output from the LLM. Sometimes the Judge agent would return feedback outside the expected JSON format. That single line of extra text caused my parser to fail. It felt like debugging a conversation — you know what the model means, but you can’t let it get sloppy.

The fix was using **Gemini’s structured output mode**: `model.with_structured_output(JudgeResult)`. That enforced schema validation at the API level, turning the flaky parts of the pipeline into something solid.

#Lessons Learned: From Code That Runs to Code That Lasts

After finally deploying the system on Render, I realized that working code and production-ready code are not the same thing.

Here are the takeaways I’ll carry forward:

1. **Structured Validation Is Not Optional**
Pydantic saved me more times than I can count. Without explicit schemas, I would’ve spent days chasing down format errors. Structure doesn’t slow you down; it gives you room to scale.

2. **State Machines Are a Great Way to Think**
LangGraph made me appreciate the power of explicit state. When bugs appeared, I could literally visualize where data was being dropped. That mental model — inputs, transformations, outputs — now shapes how I design all asynchronous workflows.

3. **Deployment Forces Clarity**
Deploying to Render exposed timing issues, missing environment variables, and serialization bugs that never showed up locally. It was humbling — and exactly what I needed to understand how “the real world” breaks code.

4. **AI Projects Still Require Real Engineering**
AI workflows look flashy, but most of the hard work isn’t in the prompt — it’s in ensuring reliability, handling errors, validating output, and designing clean interfaces. It’s a full-stack problem, not just a model problem.

#Where I’m Headed Next

Now that it’s live, I want to keep pushing the “self-correcting” idea further. I’m experimenting with:
* Tracking how often the Judge disagrees with the Summarizer.
* Logging refinement loops to evaluate performance over time.
* Adding async task handling for larger document batches.

Ultimately, what I’m really exploring is how systems — and developers — can learn from their own mistakes. This project made me realize that AI agents, like engineers, improve not through perfection, but through iteration. And if I can keep that mindset in my work, I’ll be learning the right way.
  ),
  user_id: admin.id,
  published_at: Time.current
)

# --- POST 2: Caching API Proxy ---
Post.create!(
  title: "Learning to Build a Faster Weather App: My Full-Stack Caching API Proxy Journey",
  body: %Q(
When I built my “Caching Weather Client,” I wanted a simple React app that shows the current weather for any city. Sounds easy, right? But as soon as I started thinking about real users, I realized: API calls cost money, and repeated requests are slow.

That’s when I decided to add a **caching proxy** between the frontend and the weather API. What I learned wasn’t just about caching — it was about designing a full-stack system that balances performance, reliability, and cost.

#What I Enjoyed

I loved designing the proxy as an **intelligent middleman**. Suddenly, I wasn’t just calling an API — I was thinking about network efficiency, data freshness, and cost management.

It felt like I was stepping into a real engineering problem:
* How do you reduce redundant API calls?
* How do you make the system fast for repeat requests?
* How do you keep the code simple without overengineering?

Implementing the cache hit path was satisfying because the response time dropped to milliseconds. Watching the frontend get instant updates while the backend only called the expensive API occasionally felt like magic.

#What I Struggled With

There were a few tricky parts that taught me more than I expected:

1. **Cache Invalidation and TTL**
I had to decide how stale data could be before fetching new info. I picked 5 minutes, which works fine for weather — it’s not life-critical if the temperature is a few minutes old.

But deciding on the right TTL made me realize there’s always a trade-off: shorter TTLs mean fresher data but more API calls and higher cost; longer TTLs save money but risk staleness. I spent a lot of time thinking through that balance.

2. **Handling Cache Misses**
On the first request for a city, the cache is empty. My first version just fetched the API, but I hadn’t considered latency for users. I learned to sequence operations carefully: check cache → fetch from API if stale → update cache → respond. It seems simple, but small mistakes here could block the frontend or return inconsistent data.

3. **Rate-Limiting by Design**
I realized that the proxy could also act as a rate limiter. Even if 10 users request “London” simultaneously, only one external API call is made in the TTL window. That was a subtle but important lesson in efficiency and cost control.

#Lessons Learned

* **Designing for scale early matters**
    Even a small app needs to think about concurrency, caching, and API limits. These design choices pay off as the app grows.

* **Simplicity wins**
    I briefly considered complex strategies like webhooks to invalidate cache, but a fixed TTL was simpler, reliable, and “good enough” for the use case.

* **Full-stack thinking is fun and hard**
    Balancing frontend expectations, backend logic, and external API constraints forced me to consider the system as a whole, not just individual layers.

* **Debugging in layers**
    If something broke, I had to check frontend request → proxy logic → cache read/write → external API. Understanding each layer helped me improve troubleshooting skills.

#Where I’m Going Next

The proxy works, but I want to explore a few improvements:
* Configurable TTL per city: Some users care more about real-time data.
* Cache prefetching: Fetch popular cities in advance to reduce first-request latency.
* Better logging: Track cache hits, misses, and API costs in production.

Building this small project gave me confidence that I can design full-stack solutions that are efficient and maintainable, even when I’m still early in my career.
  ),
  user_id: admin.id,
  published_at: 1.day.ago
)

# --- POST 3: Rails to Next.js Blog ---
Post.create!(
  title: "From Rails to Next.js: Lessons Learned Building My Personal Blog",
  body: %Q(
When I decided to build my personal blog, I wanted fast pages, structured content, and a decoupled architecture. I also wanted to challenge myself to combine what I was learning in Rails with a modern frontend framework like Next.js.

What I ended up building was more than just a blog. It was a crash course in full-stack integration, static site generation, and type safety, and it taught me lessons I’m still carrying forward as I grow as a developer.

#What I Enjoyed

* **Static Generation (SSG)**
    I loved seeing how Next.js pre-builds every blog page at build time. Visiting a post feels instant because the HTML is already generated. As someone still learning Rails, it was exciting to see how pre-rendering improves performance for readers without adding complexity to the frontend.

* **Type Safety with TypeScript**
    Using TypeScript on the frontend, I created interfaces for posts and API responses. It helped me catch mismatches between Rails JSON output and the Next.js components before they became runtime bugs. I really appreciated how this gives confidence when refactoring or adding features.

* **Decoupled Architecture**
    Having Rails serve data and Next.js render it forced me to think in API-first terms. Even though I’m still learning Rails, this made me realize how important it is to clearly define what the backend should provide, and how the frontend consumes it.

#What I Struggled With

1. **Keeping Content Fresh with Static Pages**
Static generation is fast, but it introduces stale content. When I added a new post to Rails, the Next.js page wouldn’t update until I rebuilt the site. I realized I’d need **Incremental Static Regeneration (ISR)** or a webhook from Rails to trigger rebuilds — a small but important piece to make a production-ready system.

2. **Managing API Contracts**
Even with TypeScript, I had to be careful that Rails output matched the interfaces expected by Next.js. It was easy to accidentally change a key name or data structure in Rails, which would break the frontend. This taught me the importance of **contract discipline** between frontend and backend — a lesson I’m still practicing as I grow more comfortable with Rails.

3. **Routing Nuances in Next.js**
Dynamic routes with `generateStaticParams` worked well for my blog posts, but understanding how params relate to SSG took some trial and error. I had to make sure the slug used in Rails matched the URL paths in Next.js exactly — a subtle detail that caused confusing 404 errors at first.

#Lessons Learned

* **Think API-first, even when learning backend frameworks**
    Designing Rails to serve JSON first made integration smoother and taught me good practices early on.

* **Static generation improves UX, but you need a plan for updates**
    It’s fast, but content doesn’t refresh automatically. ISR or webhooks are essential for blogs or apps with frequently updated content.

* **TypeScript + Rails = sanity**
    Strong typing on the frontend prevents small but frustrating bugs, even when the backend is still a learning project.

* **Decoupled architecture teaches discipline**
    Separating frontend and backend logic forces you to clearly define responsibilities, improving maintainability — an important habit for any developer, especially when you’re learning.

#Next Steps

I’m planning to add:
* On-demand revalidation so new posts update automatically without a rebuild.
* Search and filtering on the blog index.
* Enhanced layouts and SEO optimizations.

This project wasn’t just about making a blog — it was about exploring how frontend and backend systems can work together and how to think about the full stack as a junior developer.

By the end, I felt more confident in designing robust, maintainable systems, and more aware of the subtle challenges that arise even in seemingly simple projects.
  ),
  user_id: admin.id,
  published_at: 2.days.ago
)

puts "Seeding complete. Created #{User.count} user(s) and #{Post.count} post(s)."
