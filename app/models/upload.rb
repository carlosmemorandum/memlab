class Upload
  include ActiveModel::Model
  
  attr_accessor :quality, :image, :image_cache
  
  validates_presence_of :quality, message: "No ha puesto el valor de calidad: 30-100"
  validates_numericality_of :quality, greater_than: 29, less_than: 101, message: "No ha puesto número entre 30 - 100"
  validates :image, presence: {message: "No ha subido ninguna imagen"}

  #with_options if: :quality do |img|
  #  img.validates :image, presence: {message: "No ha subido ninguna imagen"}
  #end


end