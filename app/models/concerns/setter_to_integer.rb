module SetterToInteger
  def to_integer(*attributes)
    attributes.each do |attribute|
      define_method("#{attribute}=") do |str|
        val = if str.is_a?(Integer)
                str
              else
                str =~ /\A[-+]?[0-9]+\z/ ? str.to_i : nil
              end
        instance_variable_set("@#{attribute}", val)
      end
    end
  end
end
