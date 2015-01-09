require 'test_helper'

class OaConfigsControllerTest < ActionController::TestCase
  setup do
    @oa_config = oa_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:oa_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create oa_config" do
    assert_difference('OaConfig.count') do
      post :create, oa_config: { des: @oa_config.des, key: @oa_config.key, value: @oa_config.value }
    end

    assert_redirected_to oa_config_path(assigns(:oa_config))
  end

  test "should show oa_config" do
    get :show, id: @oa_config
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @oa_config
    assert_response :success
  end

  test "should update oa_config" do
    patch :update, id: @oa_config, oa_config: { des: @oa_config.des, key: @oa_config.key, value: @oa_config.value }
    assert_redirected_to oa_config_path(assigns(:oa_config))
  end

  test "should destroy oa_config" do
    assert_difference('OaConfig.count', -1) do
      delete :destroy, id: @oa_config
    end

    assert_redirected_to oa_configs_path
  end
end
