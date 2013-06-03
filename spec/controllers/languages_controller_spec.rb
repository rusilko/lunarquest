require File.dirname(__FILE__) + '/../spec_helper'

describe LanguagesController do
  before do
    @eng = Language.new(name: "Angielski")
    @eng.save
  end
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => Language.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Language.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "edit action should render edit template" do
    get :edit, :id => Language.first
    response.should render_template(:edit)
  end

  it "destroy action should destroy model and redirect to index action" do
    language = Language.first
    delete :destroy, :id => language
    response.should redirect_to(languages_url)
    Language.exists?(language.id).should be_false
  end
end
