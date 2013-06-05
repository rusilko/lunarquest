class Language < ActiveRecord::Base
  attr_accessible :description, :name
  has_many  :words, inverse_of: :language
  # has_many  :translations, foreign_key: 
  # has_many  :translations, foreign_key: 
  validates :name, uniqueness: {case_sensitive: false},
                   presence: true
  validates :description, length: { maximum: 150 }
end
