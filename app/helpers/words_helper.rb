module WordsHelper
  def link_to_add_translation_row(name, f, association) 
    new_object = f.object.send(association).klass.new
    new_object.build_translated_word
    id = new_object.object_id
    fields = f.simple_fields_for(association, new_object, child_index: id) do |builder|
      render 'translation_fields', f: builder
    end
    link_to(name, '#', id: "add_transl_btn", class: "btn btn-success add_transl_btn", data: {id: id, fields: fields.gsub("\n", "")})   
  end

  def setup(word,action)    
    unless word.errors.any? || action == 'new'
      # prepare translation and translated word
      word.translations.build.build_translated_word
    end
    word
  end
end
