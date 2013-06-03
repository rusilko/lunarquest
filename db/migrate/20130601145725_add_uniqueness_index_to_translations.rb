class AddUniquenessIndexToTranslations < ActiveRecord::Migration
  def change
     add_index :translations, [:original_word_id, :translated_word_id, :original_language_id, :translated_language_id],
                              unique: true, 
                              name: 'index_translations_record_uniquness'
  end
end
