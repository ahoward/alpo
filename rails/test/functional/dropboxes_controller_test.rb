require 'test_helper'

class DropboxesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dropboxes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dropbox" do
    assert_difference('Dropbox.count') do
      post :create, :dropbox => { }
    end

    assert_redirected_to dropbox_path(assigns(:dropbox))
  end

  test "should show dropbox" do
    get :show, :id => dropboxes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => dropboxes(:one).to_param
    assert_response :success
  end

  test "should update dropbox" do
    put :update, :id => dropboxes(:one).to_param, :dropbox => { }
    assert_redirected_to dropbox_path(assigns(:dropbox))
  end

  test "should destroy dropbox" do
    assert_difference('Dropbox.count', -1) do
      delete :destroy, :id => dropboxes(:one).to_param
    end

    assert_redirected_to dropboxes_path
  end
end
