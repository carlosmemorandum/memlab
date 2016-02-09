require 'i18n'

class UploadsController < ApplicationController
  
  attr_reader :small, :large, :xlarge

  def new
    @upload = Upload.new
    @upload.quality = 70
  end
  
  def index
  end
  
  def create
    @@list = []
    @upload = Upload.new(params[:upload])
    uploaded_io = @upload.image
    image_type = params[:image_type].to_i
    imgs = []
    filenames = []
    
    if @upload.valid?
      uploaded_io.each do |upfile|
        path = path(:xlarge, strip_filename(upfile.original_filename))
        File.open(path, 'wb') do |file| file.write(upfile.read)
        end
        convert(path, path, mapping(image_type, 2), false)
        optimize(path)
        imgs << path
        @@list << path
        filenames << strip_filename(upfile.original_filename)
      end
    
      imgs.each_with_index do |file, index|
        convert_more(file, filenames[index], image_type)
      end
    
      delete('export.zip')
    
      directoryToZip = Rails.root.join('public','uploads')
      @outputFile = Rails.root.join('public', 'export.zip')
      zip(directoryToZip, @outputFile, 'uploads')
    
      @@list.each do |i|
        destroy(i)
      end
      
      #flash[:notice] = "Your files were successfully uploaded. Your chose #{image_type}"
      download(@outputFile)
    else
      flash.now[:alert] = "Hay algun problema en el formulario."
      render :new
    end

  end
  
  def path(dir, file)
    path = Rails.root.join('public','uploads',"#{dir}", file)
    return path
  end
  
  def strip_filename(file)
    filename = I18n.transliterate(file).split(/\s+/).join("_").gsub("?","").downcase
    filename.sub! /\A.*(\\|\/)/, ''
    return filename
  end
  
  def timestamp(file)
    time = Time.now
    stamp =  time.strftime('%Y%m%d%H%M%S%L') + "_" + file
    return stamp
  end

  def mapping(image_type, size)
    types = { 0 => ["390x260", "600x400", "1185x1185"], 1 => ["", "960x690", "1920x1920"]}
    return types[image_type][size]
  end
  
  def convert(input, output, size, crop)
    image = MiniMagick::Image.new(input) do |b|
      if crop
        b.resize size + '^'
        b.gravity 'center'
        b.crop size + '+0+0'
      elsif
        b.resize size
      end
      b.write(output)
    end
    return image
  end
  
  def convert_more(file, filename, image_type)
    path  = [path(:small, filename), path(:large, filename)]
    if image_type == 0
      2.times do |i|
        convert(file, path[i], mapping(image_type, i), true)
        optimize(path[i])
        @@list << path[i]
      end
    elsif
      convert(file, path[1], mapping(image_type, 1), true)
      optimize(path[1])
      @@list << path[1]
    end
  end
  
  def optimize(file)
    image = ImageOptimizer.new("#{file}", quality: @upload.quality.to_i)
    image.optimize
    return image
  end
  
  def zip(dir, file, controller)
    zf = ZipFileGenerator.new(dir, file, controller)
    zf.write()
  end
  
  def download(file)
    send_file(file)
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
  
end