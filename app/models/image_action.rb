class ImageAction
  include ActiveModel::Model
  
  attr_accessor :name, :string
  attr_accessor :quality, :width, :height
  attr_accessor :progressive, :crop
  attr_accessor :image
  
  validates :width, size:true, presence: { message: "No ha puesto valor de anchura." }
  validates :height, size: true, presence: { message: "No ha puesto valor de altura." }
  validates :quality,
    presence: {
      message: "No ha puesto valor de calidad."
    },
    numericality: {
      only_integer: true,
      greater_than: 29,
      less_than: 101,
      message: "No ha puesto número entre 30 - 100"
    }
    validates :image, presence: { message: "No ha subido ninguna imagen."}

end