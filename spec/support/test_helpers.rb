module TestHelpers
  def assoc(model, relationship, opts = {})
    association = subject.class.reflect_on_association(model)
    expect(association.macro).to eq relationship
    opts.each { |k, v| expect(association.options[k]).to eq v }
  end

  def expect_error(key, msg)
    expect(subject.errors[key]).to contain_exactly(msg)
  end
end
