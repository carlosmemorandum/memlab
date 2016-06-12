require 'i18n'

class WatermarksController < ApplicationController
	include FileActions

	def export
    @file = File.new("#{FileActions::OUTPUT_FILE}", "r")
  end
	
	def new
		@watermark = Watermark.new
		@watermark.quality = 70
	end

	def create
		@watermark = Watermark.new(secure_params)
		@list = []
		@logo = 'logo_bemate_white.svg'

		if @watermark.valid?
			@watermark.image.each do |upfile|
				path = FileActions.path(FileActions.strip_filename(upfile.original_filename))
				File.open(path, 'wb') do |file| file.write(upfile.read)
				end
				FileActions.optimize(path, @watermark.quality.to_i)
				watermark_imgs(path, path)
				@list << path
			end

			FileActions.delete('export.zip', 'export.png')

			directoryToZip = Rails.root.join('public','uploads')
			@outputFile = Rails.root.join('public', 'export.zip')
			FileActions.zip(directoryToZip, @outputFile, 'watermark')

			@list.uniq.each do |i|
				FileActions.destroy(i)
			end
			
			respond_to do |format|
        if @watermark.valid?
          format.html { redirect_to watermarks_export_path }
          format.js {}
        end
      end

		else
			flash.now[:alert] = "Hay algun problema en el formulario."
			render :new
		end
	end

	def watermark_imgs(file, output)
		logo = Rails.root.join('app','assets','images', "#{@logo}")
		first_image  = MiniMagick::Image.new("#{file}")
		size = [first_image.width, first_image.height]
		image_density = ((size[0].to_f / 1440) * 72) * 2.5
		
		second_image = Rails.root.join('public', "export.png")
		if second_image
			`convert -density #{image_density} -background none #{logo} #{second_image}`
		end
		second_image  = MiniMagick::Image.new("#{second_image}")

		result = first_image.composite(second_image) do |c|
			c.compose "Softlight"
			c.gravity "SouthEast"
			c.geometry "+143+173"
		end
		result.write(output)
	end

	def download
    send_file(FileActions::OUTPUT_FILE)
  end

	private

	def secure_params
		params.require(:watermark).permit(:quality, :image => [])
	end

end