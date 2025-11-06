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
[cite_start]I recently built a self-correcting summarization workflow using **LangGraph** [cite: 96][cite_start], and it turned out to be one of those projects that teaches you as much about system design as it does about AI[cite: 96].

[cite_start]The application implements an **iterative refinement loop** with three agents[cite: 98]:
* [cite_start]A **Summarizer** that generates the initial draft[cite: 99].
* [cite_start]A **Judge** that evaluates quality and provides feedback[cite: 100].
* [cite_start]A **Refiner** that incorporates the critique[cite: 101].

[cite_start]The loop continues until the Judge approves the output[cite: 102]. [cite_start]I deployed it using Flask and Render, so users can submit text and watch the refinement process happen in real-time[cite: 102].

# [cite_start]What Worked Well [cite: 103]
[cite_start]The most satisfying part was seeing the **state machine** come together[cite: 104]. [cite_start]LangGraph's node-based architecture forces you to think explicitly about state transitions[cite: 105]. [cite_start]Each node produces output and determines the next step[cite: 105].

[cite_start]Using **Pydantic** for structured outputs made a huge difference[cite: 107]. [cite_start]By defining a schema with `should_refine: bool` and `feedback: str`, I turned the LLM from something unpredictable into a reliable component[cite: 107]. [cite_start]Type safety makes the whole system easier to reason about[cite: 108].

[cite_start]I also appreciated how LangGraph handles the orchestration layer[cite: 109]. [cite_start]You're not manually managing callbacks; you're just defining nodes and edges[cite: 110]. [cite_start]It keeps the code clean and lets you focus on the business logic[cite: 110].

# [cite_start]The Hard Parts [cite: 111]
[cite_start]**State management** was trickier than I expected[cite: 112]. [cite_start]Each node needs to explicitly return the keys you want to preserve [cite: 112][cite_start], and I initially had a node that was overwriting the entire state instead of merging updates[cite: 112]. [cite_start]The symptom was subtle: everything would work until the final node, which would fail with "summary not found"[cite: 113]. [cite_start]The lesson was clear: **implicit state updates don't work** in these architectures[cite: 115].

[cite_start]The other challenge was **enforcing structured output** from the LLM[cite: 116]. [cite_start]Even with clear prompts, the Judge would occasionally return extra commentary outside the JSON schema, breaking the parser[cite: 117]. [cite_start]I switched to **Gemini's `with_structured_output()` method** [cite: 118][cite_start], which validates at the API level and solved it completely[cite: 118, 119].

# [cite_start]What I Learned [cite: 120]
* [cite_start]**Structured validation scales**[cite: 124]. [cite_start]Pydantic schemas might feel like overhead initially, but they pay dividends when you're debugging or extending the system[cite: 124, 125].
* [cite_start]**State machines clarify control flow**[cite: 126]. [cite_start]LangGraph's explicit state management made debugging much easier[cite: 126]. [cite_start]When something broke, I could trace exactly where data was being lost or transformed incorrectly[cite: 127].
* [cite_start]**Production reveals assumptions**[cite: 128]. [cite_start]Deploying to Render exposed timing issues, request timeouts, and serialization quirks that never showed up locally[cite: 121, 129].
* [cite_start]**AI workflows are still software**[cite: 130]. [cite_start]The LLM is a component, but the real work is in validation, error handling, and system design[cite: 130].

# [cite_start]Next Steps [cite: 132]
[cite_start]Now that it's stable, I'm adding instrumentation to track performance[cite: 133]:
* [cite_start]Logging disagreement rates between the Judge and Summarizer[cite: 134].
* [cite_start]Recording refinement loop counts and feedback patterns[cite: 135].
* [cite_start]Adding async support for batch processing[cite: 136].

[cite_start]The broader takeaway is that iteration matters more than getting everything right the first time[cite: 137].
  ),
  user_id: admin.id,
  published_at: 3.days.ago
)

# --- POST 2: Caching API Proxy ---
Post.create!(
  title: "Building a Caching API Proxy for a Weather App",
  body: %Q(
[cite_start]I recently built a weather app with a **caching proxy layer** [cite: 52][cite_start], and it turned into a practical lesson in full-stack system design[cite: 52]. [cite_start]The frontend is a straightforward React app, but adding a proxy between the client and the external weather API made me think harder about performance, cost, and data freshness[cite: 53].

# [cite_start]Why a Proxy? [cite: 54]
[cite_start]The problem was simple: external API calls are expensive and slow[cite: 55]. [cite_start]If multiple users request weather for the same city within a short window, there's no reason to hit the API repeatedly[cite: 56]. [cite_start]A caching proxy solves this by storing responses temporarily and serving cached data when possible[cite: 57]. [cite_start]Implementing it yourself forces you to understand the trade-offs involved[cite: 58].

# [cite_start]What Worked Well [cite: 59]
[cite_start]Designing the proxy as an **intelligent middleman** was the most interesting part[cite: 60]. [cite_start]Instead of just forwarding requests, it makes decisions about when to use cached data versus fetching fresh information[cite: 61]. [cite_start]This shifted my thinking from "call the API" to "**manage network efficiency and cost**"[cite: 62].

[cite_start]The **cache hit path** was satisfying to implement[cite: 63]. [cite_start]Response times dropped to milliseconds for cached requests, and the backend only called the external API when necessary[cite: 63].

[cite_start]I also appreciated how the proxy naturally functions as a **rate limiter**[cite: 65]. [cite_start]If ten users request "London" simultaneously, only one external API call happens within the TTL window[cite: 66]. [cite_start]That kind of implicit optimization emerged from the design[cite: 67].

# [cite_start]The Challenges [cite: 68]
* [cite_start]**Cache invalidation and TTL selection**[cite: 69]. [cite_start]I settled on a **5-minute TTL** for weather data, as temperature changes aren't urgent enough to justify constant refreshing[cite: 69, 70]. [cite_start]This forced me to think through the trade-offs: shorter TTLs mean fresher data but higher API costs[cite: 70].
* [cite_start]**Sequencing cache operations correctly**[cite: 73]. [cite_start]The logic is: check cache, fetch from API if stale, update cache, respond[cite: 73]. [cite_start]Small mistakes in ordering could block the frontend or return inconsistent data[cite: 73]. [cite_start]I had to think carefully about error handling, too—each layer needs to degrade gracefully[cite: 75].
* [cite_start]**Handling the cold start problem**[cite: 76]. [cite_start]On the first request for any city, the cache is empty, and there's unavoidable latency[cite: 76]. [cite_start]The lesson was recognizing where complexity (like prefetching) adds value versus where it's premature optimization[cite: 77, 78].

# [cite_start]What I Learned [cite: 79]
* [cite_start]**System design is about constraints**[cite: 80]. [cite_start]I had to balance frontend expectations, backend efficiency, and external API limitations[cite: 80].
* [cite_start]**Simplicity usually wins**[cite: 82]. [cite_start]A fixed TTL was simpler, reliable, and appropriate for the problem[cite: 82]. [cite_start]Knowing when not to add complexity is as important as knowing when to add it[cite: 83].
* [cite_start]**Debugging requires understanding layers**[cite: 84]. [cite_start]When something broke, I had to trace the path through the frontend, proxy logic, cache read/write, and external API call[cite: 84].
* [cite_start]**Instrumentation matters**[cite: 86]. [cite_start]I added logging for cache hits, misses, and API calls [cite: 86][cite_start], which was essential for understanding actual versus intended behaviour[cite: 86].

# [cite_start]Next Steps [cite: 88]
[cite_start]The proxy works well, but there are a few improvements I want to explore[cite: 89]:
* [cite_start]**Configurable TTL per city**: Some locations might benefit from more frequent updates[cite: 90].
* [cite_start]**Cache prefetching**: Proactively fetch popular cities to reduce first-request latency[cite: 91].
* [cite_start]**Better monitoring**: Track cache hit rates and API costs over time to validate the design assumptions[cite: 92].

[cite_start]Building this project reinforced that even small applications benefit from thinking about concurrency, caching, and cost[cite: 93].
  ),
  user_id: admin.id,
  published_at: 2.days.ago
)

# --- POST 3: Rails to Next.js Blog ---
Post.create!(
  title: "Building a Personal Blog with Rails and Next.js",
  body: %Q(
I recently built my personal blog using **Rails as a headless CMS** and **Next.js** for the frontend. The setup is straightforward: Rails handles content through a JSON API, and Next.js generates static pages from that data. I chose this architecture partly to learn how these systems work together, but also because it keeps things cleanly separated. Rails worries about content and data; Next.js handles the rendering and performance side of things.

# What Worked Well
The big win was **static site generation**. Next.js pre-renders all the blog pages at build time, so the HTML is already there when you visit a post. It's noticeably faster than waiting for API calls or client-side rendering, making a huge difference in how snappy things feel for a blog. I'd rather have fast page loads than real-time updates for content that changes maybe once a week.

Using **TypeScript** for the frontend helped more than I expected. I defined interfaces for what the API should return, and it caught a bunch of places where the Rails JSON didn't quite match what Next.js was expecting. While not perfect, it prevents a lot of stupid mistakes.

I also appreciated being forced to think **API-first**. Instead of having Rails render HTML directly, everything goes through JSON endpoints. This made me more deliberate about what data the backend should provide and how it's structured. This fosters good habits for working on any separated frontend/backend project.

# The Tricky Parts
**Static generation is great until you realize your content is stale**. I'd add a new post to Rails, check the site, and find nothing. It took me a minute to remember I needed to rebuild. Eventually, I set up **Incremental Static Regeneration** (ISR) so pages refresh on demand, but understanding why the content wasn't updating was the first step.

**Keeping the API contract in sync** between Rails and Next.js was harder than it should have been. I'd change a field name in Rails, forget to update the TypeScript interface, and boom, broken frontend. It taught me to treat the API like an actual contract that both sides need to respect.

Next.js **routing with `generateStaticParams`** worked fine once I got it, but the learning curve was steeper than I expected. The slug format in Rails had to match exactly what Next.js expected in the URL. When they didn't match, I'd get confusing 404 errors that took longer to debug than they should have.

# What I Learned
* **API design** ended up mattering more than I thought it would. Consistent field names, proper error codes, and clear data shapes make the frontend way easier to work with.
* **Static generation is powerful, but you need a plan for how content updates**. ISR worked for me, but webhooks or scheduled rebuilds could work too. Thinking about your update frequency upfront is crucial.
* **TypeScript reduces a lot of friction once you commit to it**. Combined with a well-designed backend API, it cuts down the feedback loop for catching errors before they hit production.
* **Decoupled systems force you to think about boundaries more carefully**. The separation means Rails doesn't need to know about frontend rendering, and Next.js doesn't care about the database structure, making both sides easier to reason about.

# Next Steps
I'm working on a few improvements:
* **On-demand revalidation**: Automatically update pages when new content is published, without needing a full rebuild.
* **Search functionality**: Add filtering and search to the blog index. I'll probably go with a client-side solution to keep things simple.
* **SEO improvements**: Better metadata, structured data, and Open Graph tags for discoverability.

This project reinforced that even simple applications involve real design decisions around performance, data freshness, and system boundaries.
  ),
  user_id: admin.id,
  published_at: 1.day.ago
)

puts "Seeding complete. Created #{User.count} user(s) and #{Post.count} post(s)."
