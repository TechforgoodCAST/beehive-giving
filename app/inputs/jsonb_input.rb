class JsonbInput < Formtastic::Inputs::TextInput
  def input_html_options
    super.merge rows: 4, value: object[method].to_json
  end
end
