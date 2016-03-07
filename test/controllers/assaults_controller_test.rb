require 'test_helper'

class AssaultsControllerTest < ActionController::TestCase
  setup do
    @assault = assaults(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assaults)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assault" do
    assert_difference('Assault.count') do
      post :create, assault: { cate: @assault.cate, description: @assault.description, employees: @assault.employees, state: @assault.state }
    end

    assert_redirected_to assault_path(assigns(:assault))
  end

  test "should show assault" do
    get :show, id: @assault
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @assault
    assert_response :success
  end

  test "should update assault" do
    patch :update, id: @assault, assault: { cate: @assault.cate, description: @assault.description, employees: @assault.employees, state: @assault.state }
    assert_redirected_to assault_path(assigns(:assault))
  end

  test "should destroy assault" do
    assert_difference('Assault.count', -1) do
      delete :destroy, id: @assault
    end

    assert_redirected_to assaults_path
  end
end
