require "test_helper"

class PenilaianControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get penilaian_index_url
    assert_response :success
  end
end
