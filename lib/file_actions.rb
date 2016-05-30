module FileActions

	OUTPUT_FILE = Rails.root.join('public', 'export.zip')

	def FileActions.path(file, dir = false)
    if !dir
    	path = Rails.root.join('public','uploads', file)
    else
    	path = Rails.root.join('public','uploads',"#{dir}", file)
    end
    return path
  end

  def FileActions.strip_filename(file)
		filename = I18n.transliterate(file).split(/\s+/).join("_").gsub("?", "").downcase.split(/\.\w{3}$/).join("")
		filename.sub! /\A.*(\\|\/)/, ''
		return filename + ".jpg"
	end

	def FileActions.optimize(file, quality)
		image = ImageOptimizer.new("#{file}", quality: quality)
		image.optimize
		return image
  end

	def FileActions.delete(*args)
		args.each do |i|
			path = Rails.root.join('public', i)
			if File.exist?(path)
				FileActions.destroy(path)
			end
		end
	end
  
  def FileActions.destroy(file)
    File.delete(file)
  end

  def FileActions.zip(dir, file, controller)
    zf = ZipFileGenerator.new(dir, file, controller)
    zf.write()
  end
end