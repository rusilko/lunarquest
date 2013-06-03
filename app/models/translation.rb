class Translation < ActiveRecord::Base

  attr_accessible :original_word_id, :translated_word_id, :translated_word

  belongs_to :original_word, class_name: "Word"
  belongs_to :translated_word, class_name: "Word"
  # TO-DO Check if statement belowe are any helpful for the data model
  # belongs_to :original_language, class_name: "Language"
  # belongs_to :translated_language, class_name: "Language"

  after_initialize :set_language_ids
  
  validates :original_word_id, presence: true,
                               uniqueness: { scope: [ :original_language_id, :translated_word_id, :translated_language_id] }
  validates :translated_word_id, presence: true
  validates :original_language_id, presence: true
  validates :translated_language_id, presence: true
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
    query = "original_word_id = ? AND original_language_id = ? AND translated_word_id = ? AND translated_language_id = ?" 
    Translation.where(query, word1_id, language1_id, word2_id, language2_id).exists? || Translation.where(query, word2_id, language2_id, word1_id, language1_id).exists?
  end

  protected
  def ensure_words_have_proper_language_ids
    if self.original_word.try(:language_id) != self.original_language_id || self.translated_word.try(:language_id) != self.translated_language_id
      errors[:base] << "This translation is invalid because language_ids don't match"
    end
  end

  def set_language_ids
    self.original_language_id     = self.original_word.language_id
    self.translated_language_id   = self.translated_word.language_id
  end
end
