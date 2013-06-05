# encoding: utf-8
require 'spec_helper'

describe "WordPages" do

  before(:each) do
    @pl   = Language.create(name: "Polski")
    @eng  = Language.create(name: "Angielski")
    @esp  = Language.create(name: "Hiszpański")

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

  let(:word) { @pies_pl }
  subject { page }

  describe "index page" do  
    before { visit words_path }

    it { should have_title('Words') }

    it { should have_button('Search') }
    describe "when clicking search button" do
      before { click_on 'Search' }
      specify { current_path.should == words_path }
    end    

    it "should list each word" do
      Word.all.each do |word|
        page.should have_link(word.value, href: word_path(word.id))
        page.should have_link('Edit', href: edit_word_path(word.id))
        page.should have_link('Destroy', href: word_path(word.id))
      end
    end   

    it { should have_button('+ New Word') }

    describe "when clicking new word button" do
      before { click_on '+ New Word' }
      specify { current_path.should == new_word_path }
    end

    describe "when clicking word edit button" do
      before { first('a', text: 'Edit').click }
      specify { current_path.should == edit_word_path(word.id) }
    end

    describe "when clicking word destroy button" do
      it "should destroy word" do
        expect { first('a', text: 'Destroy').click }.to change(Word, :count).by(-1)
        page.should have_content("Successfully destroyed word.")
      end
    end
  end

  describe "search" do
    before { visit words_path }

    describe "with empty field" do
      before do         
        click_on 'Search'
      end

      it "should not list any words" do
        Word.all.each do |word|
          page.should_not have_link(word.value, href: word_path(word.id))
          page.should_not have_link('Edit', href: edit_word_path(word.id))
          page.should_not have_link('Destroy', href: word_path(word.id))
        end
      end

      it { should_not have_selector "table" }
    end

    describe "with non-existing word" do
      before do   
        fill_in 'query', with: "doggie"     
        click_on 'Search'
      end

      it "should not list any words" do
        Word.all.each do |word|
          page.should_not have_link(word.value, href: word_path(word.id))
          page.should_not have_link('Edit', href: edit_word_path(word.id))
          page.should_not have_link('Destroy', href: word_path(word.id))
        end
      end
      it { should_not have_selector "table" }
    end

    describe "with existing word" do
      before do   
        fill_in 'query', with: "dog"     
        click_on 'Search'
      end

      it "should not list any words other than dog" do
        Word.all.reject {|w| w.value == "dog" }.each do |word|
          page.should_not have_link(word.value, href: word_path(word.id))
          page.should_not have_link('Edit', href: edit_word_path(word.id))
          page.should_not have_link('Destroy', href: word_path(word.id))
        end
      end

      it do
        should have_link(@dog_en.value, href: word_path(@dog_en.id))
        should have_link('Edit', href: edit_word_path(@dog_en.id))
        should have_link('Destroy', href: word_path(@dog_en.id))
      end 
      
      it { should have_selector "table" }
    end
  end

  describe "creating new word with one meaning" do
    before do
      visit words_path      
      fill_in 'w', with: "monkey"     
      click_on '+ New Word'      
      select('Angielski', :from => 'word_language_id')
      fill_in 'word_translations_attributes_0_translated_word_attributes_value', with: "malpa"
      select('Polski', :from => 'word_translations_attributes_0_translated_word_attributes_language_id') 
    end

    it { should have_field('word_value', :with => 'monkey')}
    it { should have_link('+ Add meaning') }
    it { should have_button('Create Word') }  
    it { should have_select('word_language_id', selected: 'Angielski')}
    it { should have_field('word_translations_attributes_0_translated_word_attributes_value', with: "malpa")}
    it { should have_field('word_value', with: "monkey")}
    it { should have_select('word_translations_attributes_0_translated_word_attributes_language_id', selected: 'Polski')}

    it "should have been transaled" do
      click_button "Create Word"
      x = Word.find_by_value("malpa")
      Word.find_by_value("monkey").should_not be_nil
      Word.find_by_value("monkey").meanings_in(Language.find_by_name("Polski")).should include(x) 
    end

    describe "submitting" do
      subject { lambda { click_button "Create Word" } }

      it { should change { Word.count }.by 2 }
      it { should change { Translation.count }.by 1 }
    end
  end

  describe "creating new word with two meanings", js: true do

    before do
      visit new_word_path      
      fill_in 'word_value', with: "tree"
      select('Angielski', :from => 'word_language_id')
      fill_in 'word_translations_attributes_0_translated_word_attributes_value', with: "drzewo"
      select('Polski', :from => 'word_translations_attributes_0_translated_word_attributes_language_id') 
    end

    let(:add_meaning_btn) { page.find_link('+ Add meaning')}

    it "should display new translation fields" do
      page.should have_selector('div.translation_fields')
      add_meaning_btn.click
      page.should have_selector('div.translation_fields', count: 2)
    end

    describe "submitting" do
      before do        
        add_meaning_btn.click
        page.all('div.translation_fields')[1].find('input').set("drzewko")
        page.all('div.translation_fields')[1].find('select').find('option',text: "Polski").click
      end
      subject { lambda { click_button "Create Word" } }
      it { should change { Word.count }.by 3 }
      it { should change { Translation.count }.by 2 }
    end
  end
end
