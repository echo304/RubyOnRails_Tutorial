require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Test Test", email: "test@test.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
    assert_equal @user.name, "Test Test"
  end

  test "name should not be blank" do
    @user.name = "      "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be blank" do
    @user.email = "      "
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com user@example..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be uniq" do
    duplicated_user = @user.dup
    duplicated_user.email = @user.email.upcase
    @user.save
    assert_not duplicated_user.valid?
  end

  test "email address should be saved as lower-case" do
    uppercase = "UPPERCASE@TEST.COM"
    @user.email = uppercase
    @user.save
    assert_equal uppercase.downcase, @user.reload.email
  end

  test "password should not be blank" do
    @user.password = @user.password_confirmation = "        "
    assert_not @user.valid?
  end

  test "password should have minimum length of 6" do
    @user.password = @user.password_confirmation = "12345"
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following? archer
    michael.follow archer
    assert michael.following? archer
    assert archer.followers.include? michael
    michael.unfollow archer
    assert_not michael.following? archer
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
    lana.microposts.each do |post|
      assert michael.feed.include? post
    end
    michael.microposts.each do |post|
      assert michael.feed.include? post
    end
    archer.microposts.each do |post|
      assert_not michael.feed.include? post
    end
  end
end
