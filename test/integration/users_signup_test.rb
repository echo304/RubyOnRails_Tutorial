require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_select 'form[action="/signup"]'
    assert_no_difference 'User.count' do
      post users_path, params: {
        user: {
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation' do
      assert_select 'div', "The form contains 4 errors."
    end
    assert_select 'div.field_with_errors', 8
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: "test",
          email: "user@valid.com",
          password: "asdfasdf",
          password_confirmation: "asdfasdf"
        }
      }
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
