class Optimize
  include ActiveModel::Model
  
  attr_accessor :name, :string
  attr_accessor :movil, :string
  attr_accessor :general, :string
  
  validates_presence_of :name
  
end