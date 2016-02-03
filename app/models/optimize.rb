class Optimize
  include ActiveModel::Model
  
  attr_accessor :name, :string
  
  validates_presence_of :name
  
end