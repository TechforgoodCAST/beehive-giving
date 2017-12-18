class MonthInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options)
    input_html_options[:min] ||= 0
    super + ' months'
  end
end
