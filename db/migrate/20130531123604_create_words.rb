class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :value, null: false
      t.string :details
      t.references :language, null: false

      t.timestamps
    end
    add_index :words, :value
    add_index :words, [:value, :language_id], unique: true
  end
end
