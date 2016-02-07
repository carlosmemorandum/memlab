class Optimize
  include ActiveModel::Model
  
  attr_accessor :name, :string
  attr_accessor :movil, :string
  attr_accessor :general, :string
  attr_accessor :image
  
  validates_presence_of :name, message: "El nombre no puede ser vacío."
  validates_presence_of :image, message: "No ha subido ninguna imagen."
  validates_format_of :name, with: /\A.+\#idioma\#.*\z/i, message: "No ha puesto nombre con patron #idioma#, por ejemplo: donyo_parking_#idioma#"
  
end