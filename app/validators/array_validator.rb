# TODO: spec
class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, "can't be blank") if value.blank?
    return record.errors.add(attribute, 'not an array') unless value.is_a? Array

    validate_inclusion(record, attribute, remove_blanks(value))
  end

  private

    def remove_blanks(value)
      value.reject(&:blank?)
    end

    def raise_arg_error
      return if @options.key?(:in) && @options[:in].is_a?(Array)

      raise ArgumentError, 'A configuration hash with option :in must be ' \
                           'supplied, e.g. { in: [0, 1, 2] }'
    end

    def validate_inclusion(record, attribute, value)
      raise_arg_error
      record.errors.add(attribute, 'not included in list') unless
        (value & @options[:in]).length == value.length
    end
end
