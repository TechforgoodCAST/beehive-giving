class Hash # TODO: deprecated
  def except_nested_key(key)
    copy = clone
    copy.each { |_, v| v.delete(key) if v.is_a? Hash }
  end

  def all_values_for(key, result = [])
    each do |k, v|
      result << v if k == key
      v.all_values_for(key, result) if v.is_a? Hash
    end
    result
  end

  def root_all_values_for(key, result = {})
    each { |k, v| result[k] = v.all_values_for(key) }
    result
  end
end
