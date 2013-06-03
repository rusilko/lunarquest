require 'spec_helper'

describe WordsController do
  before do
    @eng = Language.new(name: "Angielski")
    @word = Word.new(value: "Bread")
    @word.language = @eng
    @word.save!
  end

  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => Word.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Word.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "edit action should render edit template" do
    get :edit, :id => Word.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    Word.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Word.first
    response.should redirect_to(word_url(assigns[:word]))
  end

  it "destroy action should destroy model and redirect to index action" do
    word = Word.first
    delete :destroy, :id => word
    response.should redirect_to(words_url)
    Word.exists?(word.id).should be_false
  end
end
