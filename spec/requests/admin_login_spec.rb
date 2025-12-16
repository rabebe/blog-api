require 'rails_helper'

RSpec.describe "Admin login", type: :request do
  let(:admin) { User.create!(username: "adminuser", email: "admin@test.dev", password: "pAssWord12345", is_admin: true) }

  it "allows valid admin to login" do
    post "/login", params: { email: admin.email, password: "pAssWord12345" }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include("token")
  end

  it "blocks invalid login" do
    post "/login", params: { email: admin.email, password: "wrongpassword" }
    expect(response).to have_http_status(:unauthorized)
  end
end
