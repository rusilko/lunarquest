class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.integer :original_word_id, null: false
      t.integer :original_language_id, null: false
      t.integer :translated_word_id
      t.integer :translated_language_id

      t.timestamps
    end
    add_index :translations, :original_word_id
    add_index :translations, :translated_word_id
    add_index :translations, [:original_word_id, :original_language_id], name: 'index_translations_word_in_original_language'
    add_index :translations, [:translated_word_id, :translated_language_id], name: 'index_translations_word_in_translated_language'
    add_index :translations, [:original_word_id, :original_language_id, :translated_language_id], name: 'index_translations_original_to_translated'
    add_index :translations, [:translated_word_id, :translated_language_id, :original_language_id], name: 'index_translations_translated_to_original'
  end
end
