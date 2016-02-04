class OptimizesController < ApplicationController

  attr_reader :large, :xlarge
  
  def new
    @optimize = Optimize.new
  end
  
  def create
    @optimize = Optimize.new(secure_params)
    if @optimize.movil == ""
      @optimize.movil = 'movil'
    end
    if @optimize.general == ""
      @optimize.general = 'general'
    end
    
    uploaded_io = params[:optimize][:image]
    dirs = ['xlarge', 'large']
    
    if @optimize.valid?
      uploaded_io.each do | upfile |
        dirs.each do |dir|
          #path = path(dir, strip_filename(@optimize.name))
          path = path(dir, strip_filename(upfile))
          File.open(path, 'wb') do |file| file.write(upfile.read)
          end
          optimize(path)
        end
      end
      Rails.logger.debug "Muj debug, movil: #{@optimize.movil}, general je: #{@optimize.general}"
      redirect_to root_path
    else
      flash.now[:alert] = "Por favor indica el nombre del archivo"
      render :new
    end
  end
  
  def path(dir, file)
    path = Rails.root.join('public','uploads',"#{dir}", file)
    return path
  end
  
  def strip_filename(file)
    @file = I18n.transliterate(file.original_filename.downcase)
    parse = @file.split(/\s+/)
    res = parse.join("_")
    parse_extension = res.split(/\.\w{3}$/)
    return parse_extension.join("") + ".jpg"
  end
  
  def optimize(file)
    image = ImageOptimizer.new("#{file}", quality: 80)
    image.optimize
    return image
  end
  
  private
  
  def secure_params
    params.require(:optimize).permit(:name, :movil, :general)
  end
end