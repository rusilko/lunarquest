# encoding: utf-8
FactoryGirl.define do

  factory :language do
    langs = %w(Angielski Polski Hiszpański)
    sequence(:name) { |n| langs[n-1] }
  end  

  factory :word do
    value = Faker::Lorem.words(1)
    language
  end

  # factory :translation do
  #   number_of_participants 10
  #   price_per_participant  1500
  #   quote
  # end

end