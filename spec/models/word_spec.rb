# encoding: utf-8
require 'spec_helper'

describe Word do
  
  # Create model instances
  before do 
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
  end

  before(:each) do
    @word = Word.new(value: "Bread")
    @word.language = @eng
  end

  # Set subject for following test cases
  subject { @word }
  
  # Responses to methods
  it { should respond_to(:value) }
  it { should respond_to(:language_id) }
  it { should respond_to(:details) }
  it { should respond_to(:add_meaning_in) }
  it { should respond_to(:meanings_in) }
  its(:language) { should == @eng }
  
  it { should be_valid }

  # Validations

  describe "when value is not present" do    
    before { @word.value = " " }
    it { should_not be_valid }
  end

  describe "when language is not present" do
    before { @word.language = nil }
    it { should_not be_valid }
  end

  describe "when value is not unique within language scope" do
    before do
      @eng.save
      @other_word = @word.dup
      @other_word.language = @eng
      @other_word.save
    end
    it "should not be saved to db" do
      expect do
        @word.save(validate: false)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    before do
      @other_word.value.upcase!
      @other_word.save
      @word.language_id = @word.language.id
    end
    it { should_not be_valid }      
  end

  describe "when value is not unique but language is different" do
    before do
      @other_word = @word.dup
      @other_word.language = @pl
      @other_word.save
    end
    it "should be saved to db" do
      expect do
        @word.save(validate: false)
      end.not_to raise_error
    end

    before do
      @word.language_id = @word.language.id
    end
    it { should be_valid } 
  end

  # Associations
  describe "Associations" do
    
    describe "adding meaning when translated word exist" do
      it "should be saved in db" do
        expect { @pies_pl.add_meaning_in(@eng,"dog") }.to change(Translation, :count).by(1)
      end 
    end

    describe "adding meaning when translated word doesn't exist" do
      it "should be saved in db" do
        expect { @pies_pl.add_meaning_in(@eng,"puppy") }.to change(Word, :count).by(1)
        expect { @pies_pl.add_meaning_in(@eng,"puppiy") }.to change(Translation, :count).by(1)
      end 
    end

    describe "having a meaning in a language" do
      before  { @pies_pl.add_meaning_in(@eng,"dog") }
      specify { @pies_pl.meanings_in(@eng).should include(@dog_en) }
    end

    describe "having multiple meanings in a language" do
      before  do 
        @pies_pl.add_meaning_in(@eng,"dog")
        @pies_pl.add_meaning_in(@eng,"puppie")
      end
      specify { @pies_pl.meanings_in(@eng).should include(@dog_en, Word.find_by_value("puppie")) } 
    end

    describe "adding meaning should also create inferred meaning" do
      before do 
        @pies_pl.add_meaning_in(@eng,"dog")
      end
      specify { @dog_en.meanings_in(@pl).should include(@pies_pl) } 
    end

    describe "adding meaning that translation already exists for" do
      before do
        @pies_pl.add_meaning_in(@eng,"dog")
      end
      it "should not be saved in db" do
        expect { @pies_pl.add_meaning_in(@eng,"dog") }.not_to change(Translation, :count).by(1)
      end
    end

    describe "adding meaning that inferred translation already exists for" do
      before do
        @pies_pl.add_meaning_in(@eng,"dog")
      end
      it "should not be saved in db" do
        expect { @dog_en.add_meaning_in(@pl,"PIES") }.not_to change(Translation, :count).by(1)
      end
    end
  end
  # Other Test Cases
  
end
