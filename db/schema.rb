# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130601145725) do

  create_table "languages", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "languages", ["name"], :name => "index_languages_on_name", :unique => true

  create_table "translations", :force => true do |t|
    t.integer  "word_id",                :null => false
    t.integer  "original_language_id",   :null => false
    t.integer  "translated_word_id"
    t.integer  "translated_language_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "translations", ["translated_word_id", "translated_language_id", "original_language_id"], :name => "index_translations_translated_to_original"
  add_index "translations", ["translated_word_id", "translated_language_id"], :name => "index_translations_word_in_translated_language"
  add_index "translations", ["translated_word_id"], :name => "index_translations_on_translated_word_id"
  add_index "translations", ["word_id", "original_language_id", "translated_language_id"], :name => "index_translations_original_to_translated"
  add_index "translations", ["word_id", "original_language_id"], :name => "index_translations_word_in_original_language"
  add_index "translations", ["word_id", "translated_word_id", "original_language_id", "translated_language_id"], :name => "index_translations_record_uniquness", :unique => true
  add_index "translations", ["word_id"], :name => "index_translations_on_word_id"

  create_table "words", :force => true do |t|
    t.string   "value",       :null => false
    t.string   "details"
    t.integer  "language_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "words", ["value", "language_id"], :name => "index_words_on_value_and_language_id", :unique => true
  add_index "words", ["value"], :name => "index_words_on_value"

end
