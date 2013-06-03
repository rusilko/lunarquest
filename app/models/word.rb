class Word < ActiveRecord::Base
  attr_accessible :details, :value, :language_id, :translations_attributes
  belongs_to  :language

  has_many :translations, foreign_key: "original_word_id", autosave: true
  has_many :direct_meanings, through: :translations, source: :translated_word

  has_many :reverse_translations, foreign_key: "translated_word_id", class_name: "Translation", autosave: true
  has_many :inferred_meanings, through: :reverse_translations, source: :original_word 

  accepts_nested_attributes_for :translations
  accepts_nested_attributes_for :direct_meanings

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
      self.translations << t
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

end
