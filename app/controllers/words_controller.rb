class WordsController < ApplicationController
  def index
    @languages = Language.all
    @words = if params[:query]
       Word.search(params[:query])     
    else
       Word.all
    end
  end

  def translate
    @languages = Language.all
    lang_from  = Language.find params[:language_from] unless params[:language_from].blank? 
    lang_to    = Language.find params[:language_to] unless params[:language_to].blank?
    unless params[:query].blank? || params[:language_from].blank? || params[:language_to].blank?
      @words = Word.in_language(lang_from).search(params[:query])
      @translations = []
      @words.each do |w|
        w.meanings_in(lang_to).each { |m| @translations << m.value }
      end
    end
  end

  def show
    @word = Word.find(params[:id])
  end

  def new
    @word = Word.new
  end

  def create
    @word = Word.new(params[:word])
    if @word.save
      redirect_to @word, :notice => "Successfully created word."
    else
      render :action => 'new'
    end
  end

  def edit
    @word = Word.find(params[:id])
  end

  def update
    @word = Word.find(params[:id])
    if @word.update_attributes(params[:word])
      redirect_to @word, :notice  => "Successfully updated word."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @word = Word.find(params[:id])
    @word.destroy
    redirect_to words_url, :notice => "Successfully destroyed word."
  end

end
