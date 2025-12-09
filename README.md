# Blog API

This project implements a backend API for managing blog post content, featuring JWT-based authentication and a delegated authorization model where only a single designated administrator can perform write operations (Create, Update, Delete).

## Key Features

- JWT Authentication: All authorized API requests must include a valid JSON Web Token.
- Admin-Only Write Access: All endpoints that modify data (`POST, PUT/PATCH, DELETE`) are secured by an authorize_admin filter.
- Public Read Access: The list of all posts (GET /posts) and individual posts (`GET /posts/:id`) are publicly accessible.
- Delegated Author: The authorized Admin user has the ability to create new posts and explicitly set the `user_id` of the author in the request body, allowing them to publish content on behalf of any user in the system.

## Security Model

The system operates on two distinct identity checks:

1. Authorization (Who is allowed in?): The `before_action :authorize_admin` filter checks the user_id inside the JWT token provided in the Authorization header. This ID must match the Admin's internal database ID (which is determined by the configured email/password) to pass.

    - *The user needs to be the Admin to execute the request.*

2. Ownership (Who is the post assigned to?): The `post_params method` explicitly permits the user_id field from the request body. When the Admin creates a post, they are simply telling the database, "Save this post, and set its author ID to X."

    - *The `user_id` set in the request body can be any valid user ID in the database, even if that user is not the Admin.*

## Setup and Installation

### Prerequisites

- Ruby 3.4.2

- Rails 8.1.1

- PostgreSQL

### Local Setup

1. Clone the repository:
    ```
    git clone https://github.com/rabebe/blog-api
    cd secure-content-api
    ```

2. Install dependencies:

    ```
    bundle install
    ```

3. Configure Environment Variables: Create a .env file in the root directory. This file is used to configure the identity of the single administrative user, whose ID the application uses for authorization checks.

    Note on Secrets: The `SECRET_KEY_BASE` for JWT encryption is handled automatically by Rails using the encrypted credentials file (credentials.yml.enc).

    ```# .env file content
    # The email and password used to identify (and possibly seed) the single Admin user
    ADMIN_EMAIL=admin@example.com
    ADMIN_PASSWORD=supersecurepassword
    ```

4. Database Setup:

    ```
    rails db:create
    rails db:migrate
    # Ensure this command seeds the Admin user using the environment variables above
    rails db:seed
    ```

5. Run the Server:

    ```
    rails server
    ```

### Database Operations

A custom Rake task is available for reliably resetting the Post data without affecting other tables like Users. This is highly useful for resetting development or staging environments to a known baseline.

| Command | Purpose |
|---------|---------|
| rails db:safe_reseed | Safe Reset: Deletes all records from the posts table, resets the primary key ID counter back to 1, and re-runs the db/seeds.rb file to create fresh posts. |


## API Endpoints

The base URL for the API is assumed to be http://localhost:3000 locally.

| HTTP Method | Path | Description | Authorization Required |
|-------------|------|-------------|------------------------|
| GET | /posts | Retrieves a list of all posts. | None
| GET | /posts/:id | Retrieves a specific post. | None
| POST | /posts | Creates a new post. (Admin Only) | JWT Token (Must be Admin)
| PUT/PATCH | /posts/:id | Updates an existing post. (Admin Only) | JWT Token (Must be Admin)
| DELETE | /posts/:id | Deletes a specific post. (Admin Only) | JWT Token (Must be Admin)

Example Request `(POST /posts)`

To create a new post and assign it to a non-admin user (e.g., `user_id: 99`), the Admin would send:

Headers:

```
Authorization: Bearer [Admin's JWT Token]
Content-Type: application/json
```

Body:

```
{
  "post": {
    "title": "A New Article",
    "body": "This was published by the Admin but authored by User 99.",
    "user_id": 99 
  }
}
```

The `post_params` method handles the `user_id` safely because the request has already been authenticated as coming from the trusted Admin account.