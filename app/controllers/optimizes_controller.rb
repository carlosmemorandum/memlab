require 'i18n'

class OptimizesController < ApplicationController
  include FileActions

  attr_reader :large, :xlarge

  def export
    @file = File.new("#{FileActions::OUTPUT_FILE}", "r")
  end
  
  def new
    @optimize = Optimize.new
    @optimize.movil = 'movil'
    @optimize.general = 'general'
    @optimize.quality = 70
  end
  
  def create
    @optimize = Optimize.new(params[:optimize])
    @list = []
    
    if @optimize.valid?
      @optimize.image.each do |upfile|
        path = FileActions.path(FileActions.strip_filename(map_lang(upfile.original_filename, @optimize.name)), map_dir(upfile.original_filename))
        File.open(path, 'wb') do |file| file.write(upfile.read)
        end
        FileActions.optimize(path, @optimize.quality.to_i)
        @list << path
      end
      
      FileActions.delete('export.zip')
      
      directoryToZip = Rails.root.join('public','uploads')
      @outputFile = Rails.root.join('public', 'export.zip')
      FileActions.zip(directoryToZip, @outputFile, 'optimize')
    
      @list.uniq.each do |i|
        FileActions.destroy(i)
      end

      respond_to do |format|
        if @optimize.valid?
          format.html { redirect_to optimizes_export_path }
          format.js {}
        end
      end

    else
      flash.now[:alert] = "Hay algun problema en el formulario."
      render :new
    end
  end
  
  def map_dir(file)
    if file.scan(/_#{@optimize.movil}(_| |)/) != []
      return :large
    else
      return :xlarge
    end
  end
  
  def map_lang(filename, name)
    if filename.downcase.scan(/_(en|es|de|fr|it|pt|eu|hu)\./) != []
      return name.gsub(/(_| |)#idioma#(_| |)/, "_#{$1}")
    else
      return name.gsub(/(_| |)#idioma#(_| |)/, "_es")
    end
  end

  def download
    send_file(FileActions::OUTPUT_FILE)
  end
end