require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { department: @user.department, dept_code: @user.dept_code, email: @user.email, expire_date: @user.expire_date, mgr_code: @user.mgr_code, password_digest: @user.password_digest, remember_token: @user.remember_token, remember_token_expires_at: @user.remember_token_expires_at, role_group: @user.role_group, title: @user.title, uid: @user.uid, user_name: @user.user_name }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { department: @user.department, dept_code: @user.dept_code, email: @user.email, expire_date: @user.expire_date, mgr_code: @user.mgr_code, password_digest: @user.password_digest, remember_token: @user.remember_token, remember_token_expires_at: @user.remember_token_expires_at, role_group: @user.role_group, title: @user.title, uid: @user.uid, user_name: @user.user_name }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
