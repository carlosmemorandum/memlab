class Optimize
  include ActiveModel::Model
  
  attr_accessor :name, :string
  attr_accessor :movil, :string
  attr_accessor :general, :string
  attr_accessor :quality
  attr_accessor :image
  
  validates_presence_of :quality, message: "No ha puesto el valor de calidad: 30-100"
  validates_presence_of :movil, message: "No ha puesto la clave para móvil"
  validates_presence_of :general, message: "No ha puesto la clave para general"
  validates_numericality_of :quality, greater_than: 29, less_than: 101, message: "No ha puesto número entre 30 - 100"
  validates_presence_of :name, message: "El nombre no puede ser vacío."
  validates_presence_of :image, message: "No ha subido ninguna imagen."
  validates_format_of :name, with: /\A.+\#idioma\#.*\z/i, message: "No ha puesto nombre con patron #idioma#, por ejemplo: donyo_parking_#idioma#"
  
end