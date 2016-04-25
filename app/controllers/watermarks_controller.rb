require 'i18n'

class WatermarksController < ApplicationController
	
	def new
		@watermark = Watermark.new
		@watermark.quality = 70
	end

	def create
		@watermark = Watermark.new(secure_params)
		@list = []
		@logo = 'logo_bemate_white.png'

		if @watermark.valid?
			@watermark.image.each do |upfile|
				path = path(strip_filename(upfile.original_filename))
				File.open(path, 'wb') do |file| file.write(upfile.read)
				end
				optimize(path)
				watermark_imgs(path, path)
				@list << path
			end

			delete('export.zip')

			directoryToZip = Rails.root.join('public','uploads')
			@outputFile = Rails.root.join('public', 'export.zip')
			zip(directoryToZip, @outputFile, 'watermark')

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
    filename = I18n.transliterate(file).split(/\s+/).join("_").gsub("?", "").downcase.split(/\.\w{3}$/).join("")
    filename.sub! /\A.*(\\|\/)/, ''
    return filename + ".jpg"
  end

  def optimize(file)
    image = ImageOptimizer.new("#{file}", quality: @watermark.quality.to_i)
    image.optimize
    return image
  end

  def watermark_imgs(file, output)
		logo = Rails.root.join('app','assets','images', "#{@logo}")
		first_image  = MiniMagick::Image.new("#{file}")
		second_image = MiniMagick::Image.new("#{logo}")
		result = first_image.composite(second_image) do |c|
			c.compose "Softlight"
			c.gravity "SouthEast"
			c.geometry "+143+173"
		end
		result.write(output)
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

	private

	def secure_params
		params.require(:watermark).permit(:quality, :image => [])
	end


end