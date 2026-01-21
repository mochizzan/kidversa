require "test_helper"

class SiswaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get siswa_index_url
    assert_response :success
  end
end
