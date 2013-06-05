class Word < ActiveRecord::Base
  attr_accessor :double_error
  attr_accessible :details, :value, :language_id, :translations_attributes
  belongs_to  :language, inverse_of: :words

  has_many :translations, autosave: true, inverse_of: :word, dependent: :destroy
  has_many :direct_meanings, through: :translations, source: :translated_word

  has_many :reverse_translations, foreign_key: "translated_word_id", class_name: "Translation", dependent: :destroy, autosave: true
  has_many :inferred_meanings, through: :reverse_translations, source: :word 

  accepts_nested_attributes_for :translations, allow_destroy: true, 
                                reject_if: :t_word_blank?
  before_validation :b_check_for_double_errors, only: :value
  before_validation :a_check_if_translated_word_exists, only: :translations

  validates   :value, presence: true,
                      uniqueness: { case_sensitive: false, scope: :language_id}
  validates   :language, presence: true
 
  scope :in_language, lambda { |*args| {conditions: ["language_id = ?", (args.first.id || 1)]} }

  def meanings_in(language)
    direct = self.direct_meanings.where("translated_language_id = ?", language.id) 
    inferred = self.inferred_meanings.where("original_language_id = ?", language.id) 
    direct + inferred
  end

  def add_meaning_in(language,translated_word_value)
    # TO-DO: Assuming for now that language is an existing Language object    
    trans_word = Word.find_or_create_by_value_and_language_id(translated_word_value,language.id)
    unless Translation.translation_exists?(self, self.language, trans_word, trans_word.language)
      t = self.translations.build(translated_word: trans_word)
      t.save
    end   
  end

  def self.find_or_create_by_value_and_language_id(word_value, language_id, &block)
    obj = self.find_by_value_and_language_id(word_value, language_id) || Language.find(language_id).words.create(value: word_value)
  end

  def self.word_exists?(word_value,language)
    Word.where("value = ? AND language_id = ?", word_value, language.id).exists?
  end  

  def self.search(query)
    if query
      find(:all, conditions: ['value @@ :q', q: query])
    else
      find(:all)
    end
  end

  def a_check_if_translated_word_exists
    wrong_translations, good_translations = [], []
    self.translations.each do |translation|
      # first check if there are two identical [words,langs] in currently analyzed form
      if (wrong_translations+good_translations).map(&:translated_word).
        map { |tw| [tw.value,tw.language] }.include?([translation.translated_word.value, translation.translated_word.language])
        # set the double error virtual attr for translation 
        # (it will be proxied to translated_word in translation before_validation filter)
        translation.double_t_word_error = :same_form
        wrong_translations << translation
        next
      end
      if w = Word.find_by_value_and_language_id(translation.translated_word.value,translation.translated_word.language_id)
        # if Translation.find_by_translated_word_id_and_translated_language_id(w.id, w.language_id)
        if  Translation.translation_exists?(self, self.language, w, w.language)  
          translation.double_t_word_error = :same_language
          wrong_translations << translation
        else
          # discard current translation and create another one on the fly  
          add_meaning_in(w.language,w.value)
        end
      else
        good_translations << translation        
      end
    end
    self.translations = wrong_translations + good_translations
  end

  def b_check_for_double_errors
    message = case @double_error
      when :same_form
      "This translation is already on the list"
      when :same_language
      "This translation is already added to dictionary (maybe inferred)"
    end
    errors.add(:value, message) if @double_error 
  end

  def t_word_blank?(attributes)
    if attributes['translated_word_attributes']
      attributes['translated_word_attributes']['value'].blank?
    else
      false
    end
  end

end
