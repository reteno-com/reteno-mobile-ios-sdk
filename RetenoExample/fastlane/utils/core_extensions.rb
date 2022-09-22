class String
  def to_b
    self.downcase == 'true' || self == '1'
  end
end
