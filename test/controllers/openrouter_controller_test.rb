require "test_helper"

class OpenrouterControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get openrouter_index_url
    assert_response :success
  end
end
