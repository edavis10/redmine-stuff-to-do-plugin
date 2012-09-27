class Array
  # converts an array to a hash with the key = index in Array
  def to_hash
    Hash[*self.collect {|v|
           [self.index(v),v]
         }.flatten(1)]
  end unless respond_to?(:to_hash)
end
