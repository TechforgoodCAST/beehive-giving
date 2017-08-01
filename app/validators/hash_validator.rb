class HashValidator < ActiveModel::EachValidator
  OPTIONS = %i[key_in value_in].freeze

  def validate_each(record, attribute, value)
    return record.errors.add attribute, 'not a hash' unless value.is_a? Hash
    @options.each do |opt_key, opt_value|
      validator(record, attribute, value, opt_key, opt_value)
    end
  end

  private

    def validator(record, attribute, value, opt_key, opt_value)
      ensure_option opt_key
      send "validate_#{opt_key}", record, attribute, value, opt_key, opt_value
    end

    def ensure_option(opt_key)
      return if OPTIONS.include? opt_key
      raise ArgumentError, ":#{opt_key} not in #{OPTIONS}"
    end

    def ensure_array(opt_key, opt_value)
      return if opt_value.is_a? Array
      raise ArgumentError, "Value for :#{opt_key} must be Array"
    end

    def validate_key_in(record, attribute, value, opt_key, opt_value)
      ensure_array opt_key, opt_value

      value.keys.each do |k|
        next if opt_value.include? k
        record.errors.add attribute, "No #{record.class} found with '#{k}'"
      end
    end

    def validate_value_in(record, attribute, value, _, opt_value)
      case opt_value
      when :number
        ensure_value_number record, attribute, value
      when Array
        value.each do |_, v|
          next if opt_value.include? v
          record.errors.add attribute, "#{v} not included in #{opt_value}"
        end
      end
    end

    # TODO:
    # def ensure_array_format(opt_key, opt_value)
    #   return if opt_value.length == 2
    #   raise ArgumentError, "Value for :#{opt_key} must be an Array with " \
    #                        'the following format: [<start>, <end>]'
    # end

    def ensure_value_number(record, attribute, value)
      value.each do |k, v|
        next if v.is_a?(Float) || v.is_a?(Integer)
        record.errors.add attribute, "Value for '#{k}' is not a Float"
      end
    end
end
