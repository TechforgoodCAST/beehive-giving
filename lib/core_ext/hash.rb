class Hash
  def except_nested_key(key)
    copy = clone
    copy.each { |_, v| v.delete(key) if v.is_a? Hash }
  end
end
