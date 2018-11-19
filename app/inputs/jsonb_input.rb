class JsonbInput < Formtastic::Inputs::TextInput
  def input_html_options
    super.merge rows: 3, value: object[method].to_json
  end
end
