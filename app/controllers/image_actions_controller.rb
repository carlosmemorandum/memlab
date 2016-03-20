require 'i18n'

class ImageActionsController < ApplicationController
  
  def new
    @image_action = ImageAction.new
    @image_action.quality = 70
  end
  
  def create
    @image_action = ImageAction.new(params[:image_action])
    @list = []
    
    if @image_action.valid?
      @image_action.image.each do |upfile|
        path = path(strip_filename(upfile.original_filename))
        File.open(path, 'wb') do |file| file.write(upfile.read)
        end
        optimize(path)
        @list << path
      end
      
      delete('export.zip')
      
      directoryToZip = Rails.root.join('public','uploads')
      @outputFile = Rails.root.join('public', 'export.zip')
      zip(directoryToZip, @outputFile, 'image_action')
    
      @list.uniq.each do |i|
        destroy(i)
      end
      
      download(@outputFile)
      
    else
      flash.now[:alert] = "Hay algun problema en el formulario."
      render :new
    end
  end
    
  def path(file)
    path = Rails.root.join('public','uploads', file)
    return path
  end
  
  def strip_filename(file)
    filename = I18n.transliterate(file).split(/\s+/).join("_").gsub("?","").downcase
    filename.sub! /\A.*(\\|\/)/, ''
    return filename
  end
  
  def optimize(file)
    image = ImageOptimizer.new("#{file}", quality: @image_action.quality.to_i)
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