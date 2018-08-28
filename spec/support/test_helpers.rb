module TestHelpers
  def assoc(model, relationship, opts = {})
    association = subject.class.reflect_on_association(model)
    expect(association.macro).to eq relationship
    opts.each { |k, v| expect(association.options[k]).to eq v }
  end

  def expect_error(key, msg, sub = subject)
    expect(sub.errors[key]).to include(msg)
  end

  def invalid_attribute(model, attribute, value = nil)
    obj = build(model)
    obj.send("#{attribute}=", value)
    expect(obj).not_to be_valid
  end
end
