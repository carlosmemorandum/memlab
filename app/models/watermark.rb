class Watermark
	include ActiveModel::Model

	attr_accessor :quality
  attr_accessor :image

  validates_presence_of :quality, message: "No ha puesto el valor de calidad: 30-100"
  validates_numericality_of :quality, greater_than: 29, less_than: 101, message: "No ha puesto número entre 30 - 100"
  validates_presence_of :image, message: "No ha subido ninguna imagen."

end