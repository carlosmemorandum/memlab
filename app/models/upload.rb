class Upload
  include ActiveModel::Model
  
  attr_accessor :image
  
  validates_presence_of :image
end