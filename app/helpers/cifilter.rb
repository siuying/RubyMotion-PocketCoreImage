# extensions
class CIFilter
  def []=(key, value)
    self.setValue(value, forKey: key)
  end
  
  def [](key)
    self.valueForKey(key)
  end
end