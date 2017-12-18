class CurrencyInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options)
    input_html_options[:min] ||= 0
    '<span>£ </span>' + super
  end
end
