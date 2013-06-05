class Translation < ActiveRecord::Base
  attr_accessor :double_t_word_error
  attr_accessible :word, :translated_word, :translated_word_attributes

  belongs_to :word, inverse_of: :translations
  belongs_to :translated_word, class_name: "Word", autosave: true
  belongs_to :original_language, class_name: "Language"
  belongs_to :translated_language, class_name: "Language"
  # TO-DO Check if statements above are any helpful for the data model

  accepts_nested_attributes_for :translated_word
  
  before_validation :set_language_ids
  before_validation :check_for_double_errors, only: [:translated_word]
  
  # there were problems with racing conditions when using accepts_nested_attributes_for
  # Some solutions: http://stackoverflow.com/questions/14140994/failing-validations-in-join-model-when-using-has-many-through
  # Comment left for educational purposes :)
  #
  validates :word, presence: true
  validates :translated_word, presence: true
  validates :original_language, presence: true
  validates :translated_language, presence: true

  validates :word_id, uniqueness: { scope: [ :original_language_id, :translated_word_id, :translated_language_id] }
 
  # TO-DO needs a validator of "uniquness in scope of reversed translations", probably a custom validator.
  # so we don't have records like:
  # [pies, polski, dog, angielski]
  # [dog, angielski, pies, polski]
  # this is partially implemented wiht self.translation_exists? method below

  # TO-DO validation that language_ids are different in one record so there are no e.g. pol->pol translations

  # TO-DO validation that word_ids are different in one record

  # integrity check
  after_validation :ensure_words_have_proper_language_ids
  # TO-DO Check how to ensure this on a db level

  def self.translation_exists?(word1_id,language1_id,word2_id,language2_id)
    query = "word_id = ? AND original_language_id = ? AND translated_word_id = ? AND translated_language_id = ?" 
    Translation.where(query, word1_id, language1_id, word2_id, language2_id).exists? || Translation.where(query, word2_id, language2_id, word1_id, language1_id).exists?
  end

  protected
  def ensure_words_have_proper_language_ids
    if self.original_word.try(:language) != self.original_language || self.translated_word.try(:language) != self.translated_language
      errors[:base] << "This translation is invalid because language_ids don't match"
    end
  end

  def set_language_ids
    self.original_language     = self.original_word.try(:language)
    self.translated_language   = self.translated_word.try(:language)
  end

  def original_word
    word
  end

  def check_for_double_errors
    self.translated_word.double_error = self.double_t_word_error if self.translated_word
  end

end
