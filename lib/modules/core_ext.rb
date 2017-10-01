class String
  def numeric?
    Float(self) != nil rescue false
  end
end

class ActiveRecord::Base
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while self.class.exists?(column => self[column])
  end
end
