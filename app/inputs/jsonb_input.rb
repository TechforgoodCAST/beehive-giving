class JsonbInput < Formtastic::Inputs::TextInput
  def input_html_options
    super.merge rows: 3, value: object[method]
  end
end
