require 'i18n'

class UploadsController < ApplicationController
  include FileActions
  
  attr_reader :small, :large, :xlarge

  def export
    @file = File.new("#{FileActions::OUTPUT_FILE}", "r")
  end
  
  def new
    @upload = Upload.new
    @upload.quality = 70
  end

  def show
  end
  
  def create
    @@list = []
    @upload = Upload.new(secure_params)
    uploaded_io = @upload.image
    image_type = params[:image_type].to_i
    imgs = []
    filenames = []
    
    if @upload.valid?
      uploaded_io.each do |upfile|
        path = FileActions.path(strip_filename(upfile.original_filename), :xlarge)
        File.open(path, 'wb') do |file| file.write(upfile.read)
        end
        convert(path, path, mapping(image_type, 2), false)
        FileActions.optimize(path, @upload.quality.to_i)
        imgs << path
        @@list << path
        filenames << strip_filename(upfile.original_filename)
      end
    
      imgs.each_with_index do |file, index|
        convert_more(file, filenames[index], image_type)
      end
    
      FileActions.delete('export.zip')
    
      directoryToZip = Rails.root.join('public','uploads')
      FileActions.zip(directoryToZip, FileActions::OUTPUT_FILE, 'uploads')
    
      @@list.each do |i|
        FileActions.destroy(i)
      end

      respond_to do |format|
        if @upload.valid?
          format.html { redirect_to uploads_export_path }
          format.js {}
        end
      end

    else
      flash.now[:alert] = "Hay algun problema en el formulario."
      render :new
    end

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
    path  = [FileActions.path(filename, :small), FileActions.path(filename, :large)]
    if image_type == 0
      2.times do |i|
        convert(file, path[i], mapping(image_type, i), true)
        FileActions.optimize(path[i], @upload.quality.to_i)
        @@list << path[i]
      end
    elsif
      convert(file, path[1], mapping(image_type, 1), true)
      FileActions.optimize(path[1], @upload.quality.to_i)
      @@list << path[1]
    end
  end
  
  def download
    send_file(FileActions::OUTPUT_FILE)
  end

  private

  def secure_params
    params.require(:upload).permit(:quality, :image => [])
  end
  
end