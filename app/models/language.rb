class Language < ActiveRecord::Base
  attr_accessible :description, :name
  has_many  :words
  validates :name, uniqueness: {case_sensitive: false},
                   presence: true
  validates :description, length: { maximum: 150 }
end
