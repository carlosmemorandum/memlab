require 'i18n'

class OptimizesController < ApplicationController

  attr_reader :large, :xlarge
  
  def new
    @optimize = Optimize.new
    @optimize.movil = 'movil'
    @optimize.general = 'general'
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
      zip(directoryToZip, @outputFile)
    
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
    if file.scan(/_#{@optimize.movil}(|_)/) != []
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
    @file = I18n.transliterate(file)
    parse = @file.split(/\s+/)
    res = parse.join("_").gsub("?", "").downcase
    parse_extension = res.split(/\.\w{3}$/)
    return parse_extension.join("") + ".jpg"
  end
  
  def optimize(file)
    image = ImageOptimizer.new("#{file}", quality: 65)
    image.optimize
    return image
  end
  
  def zip(dir, file)
    zf = ZipFileGenerator.new(dir, file)
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