class SizeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless (value =~ /\A[0-9]+\z/ and value <= '1999') or value =~ /\A[auto]+\z/
      record.errors[attribute] << (options[:message] || "Están permitido solo los números entre 1 - 1999 e 'auto' ")
    end
  end
end