class Upload
  include ActiveModel::Model
  
  attr_accessor :image
  attr_accessor :quality
  
  validates_presence_of :quality, message: "No ha puesto el valor de calidad: 30-100"
  validates_numericality_of :quality, greater_than: 29, less_than: 101, message: "No ha puesto número entre 30 - 100"

  with_options if: :quality do |qty|
    qty.validates :image, presence: {message: "No ha subido ninguna imagen"}
  end

end