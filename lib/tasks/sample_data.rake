# encoding: utf-8
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    Language.create(name: "Angielski")
    Language.create(name: "Polski")     

  end
end