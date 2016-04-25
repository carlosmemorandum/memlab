require 'i18n'

class WatermarksController < ApplicationController

	attr_reader :xlarge
	
	def new
		@watermark = Watermark.new
		@watermark.quality = 70
	end

	def create
		@watermark = Watermark.new(secure_params)
		@list = []

		if @watermark.valid?
			@watermark.image.each do |upfile|
				path = path(:xlarge, strip_filename(upfile.original_filename))
				File.open(path, 'wb') do |file| file.write(upfile.read)
				end
				optimize(path)
				watermark_imgs(path, path)
				@list << path
			end

			delete('export.zip')

			redirect_to root_path
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
		logo = Rails.root.join('app','assets','images', 'logo_bemate.png')
		first_image  = MiniMagick::Image.new(file)
		second_image = MiniMagick::Image.new(logo)
		Rails.logger.info("My log: " + file + " - " + logo)
		result = first_image.composite(second_image) do |c|
			c.compose "Over"    # OverCompositeOp
			c.geometry "+20+20" # copy second_image onto first_image from (20, 20)
		end
		result.write(output)
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

	private

	def secure_params
		params.require(:watermark).permit(:quality, :image => [])
	end


end