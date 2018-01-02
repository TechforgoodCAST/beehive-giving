module TestHelpers
  def assoc(model, relationship, opts = {})
    association = subject.class.reflect_on_association(model)
    expect(association.macro).to eq relationship
    opts.each { |k, v| expect(association.options[k]).to eq v }
  end
end
