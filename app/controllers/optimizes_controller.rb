require 'i18n'

class OptimizesController < ApplicationController

  attr_reader :large, :xlarge
  
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
        path = path(map_dir(upfile.original_filename), strip_filename(map_lang(upfile.original_filename, @optimize.name)))
        File.open(path, 'wb') do |file| file.write(upfile.read)
        end
        optimize(path)
        @list << path
      end
      
      delete('export.zip')
      
      directoryToZip = Rails.root.join('public','uploads')
      @outputFile = Rails.root.join('public', 'export.zip')
      zip(directoryToZip, @outputFile, 'optimize')
    
      @list.uniq.each do |i|
        destroy(i)
      end
      
      download(@outputFile)

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
  
  def path(dir, file)
    path = Rails.root.join('public','uploads',"#{dir}", file)
    return path
  end
  
  def strip_filename(file)
    file.to_s do |name|
      name.I18n.transliterate
      # get only the filename, not the whole path
      name.sub! /\A.*(\\|\/)/, ''
      name.join("_").gsub("?", "").downcase
      name.split(/\.\w{3}$/)
      name.join("")
    end
    return file + ".jpg"
  end
  
  def optimize(file)
    image = ImageOptimizer.new("#{file}", quality: @optimize.quality.to_i)
    image.optimize
    return image
  end
  
  def zip(dir, file, controller)
    zf = ZipFileGenerator.new(dir, file, controller)
    zf.write()
  end
  
  def delete(file)
    path = Rails.root.join('public', file)
    if File.exist?(path)
      destroy(path)
    end
  end
  
  def destroy(file)
    File.delete(file)
  end
  
  def download(file)
    send_file(file)
  end
end