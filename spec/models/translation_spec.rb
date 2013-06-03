# encoding: utf-8
require 'spec_helper'

describe Translation do
    
  # Create model instances
  before(:each) do 
    @pl   = Language.new(name: "Polski")
    @eng  = Language.new(name: "Angielski")
    @esp  = Language.new(name: "Hiszpański")
  
    words_pl = %w(pies dom)
    words_en = %w(dog hound house)
    words_es = %w(perro casa camara)

    words_pl.each do |word| 
      w = Word.new(value: word)
      w.language = @pl
      w.save
      eval("@#{word}_pl = w") 
    end

    words_en.each do |word| 
      w = Word.new(value: word)
      w.language = @eng
      w.save
      eval("@#{word}_en = w") 
    end

    words_es.each do |word| 
      w = Word.new(value: word)
      w.language = @esp
      w.save
      eval("@#{word}_es = w") 
    end
    translation.valid?  #to set language ids
  end

  # before { @translation = Translation.new(original_word_id: @pies_pl.id, translated_word_id: @dog_en.id) }

  let(:translation ) { Translation.new(original_word_id: @pies_pl.id, translated_word_id: @dog_en.id) }
  let(:translation2) { @pies_pl.translations.build(translated_word_id: @hound_en.id)  }    
  let(:translation3) { @pies_pl.translations.build(translated_word_id: @perro_es.id) }

  # Set subject for following test cases
  subject { translation }

  # Responses to methods
  it { should respond_to(:translated_word_id) }
  it { should respond_to(:original_word_id) }
  it { should respond_to(:translated_language_id) }
  it { should respond_to(:original_language_id) }

  its(:original_word)          { should == @pies_pl }
  its(:translated_word)        { should == @dog_en  }
  its(:original_language_id)   { should == @pies_pl.language_id }
  its(:translated_language_id) { should == @dog_en.language_id  }
  
  it { should be_valid }

  # Accessible attributes
  describe "accesible attributes" do
    it "should not allow access to original_language_id attribute" do
      expect do
        Translation.new(original_language_id: 14)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to translated_language_id attribute" do
      expect do
        Translation.new(translated_language_id: 14)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  # Validation tests are turned off for nested attributes problem
  # See model for explanation
  # describe "when original_word_id is not present" do
  #   before { translation.original_word_id = nil }
  #   it { should_not be_valid }
  # end
  # describe "when original_language_id is not present" do
  #   pending "Hard to test because of setting languag_id with before_validation filter"
  #   # before do 
  #   #   translation.original_language_id = nil
  #   # end
  #   # it { should_not be_valid }
  # end
  # describe "when translated_word_id is not present" do
  #   before { translation.translated_word_id = nil }
  #   it { should_not be_valid }
  # end
  # describe "when translated_language_id is not present" do
  #   pending "Hard to test because of setting languag_id with before_validation filter"
  #   # before { translation.translated_language_id = nil }
  #   # it { should_not be_valid }
  # end

  describe "when fields are not unique in context of direct translation" do
    before do
      @other_translation = Translation.new(original_word_id: @pies_pl.id, translated_word_id: @dog_en.id)
      @other_translation.save
    end
    it "should not be saved to db" do
      expect do
        translation.save(validate: false)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
    it { should_not be_valid }   
  end

  describe "when fields are not unique in context of reversed translation" do
    before do
      @other_translation = Translation.new(original_word_id: @dog_en.id, translated_word_id: @pies_pl.id)
      @other_translation.save
    end
    it "should not be saved to db" do
      pending "As of now I don't know a way to prevent this on db level."
    end
    it { should_not be_valid }   
  end

  describe "second meaning of the same word" do
    before { translation2.save }
    it { should be_valid }
  end

  describe "in different language" do
    before { translation3.save }
    it { should be_valid }
  end
  
  # Associations
  
  # Other Test Cases
  
end
