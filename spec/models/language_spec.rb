require 'spec_helper'

describe Language do

  # Create model instances
  before(:each) { @eng = Language.new(name: "Angielski") }

  # Set subject for following test cases
  subject { @eng }

  # Responses to methods
  it { should respond_to(:name) }
  it { should respond_to(:description) }

  its(:name)  { should == "Angielski" }
  
  it { should be_valid }  

  # Validations

  describe "when name is not present" do
    before { @eng.name = " " }
    it { should_not be_valid }
  end

  describe "when name is not unique" do
    before do
      @pl = @eng.dup
      # @pl.name.upcase!
      @pl.save
    end
    it { should_not be_valid }

    it "should not be saved to db" do
      expect do
        @eng.save(validate: false)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "when description is too long" do
    before { @eng.description = "a"*151 }
    it { should_not be_valid }
  end

  # # Associations
  
  # # Other Test Cases
  
end
