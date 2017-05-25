require 'rails_helper'

describe Hash do
  it '#except_nested_key' do
    h = { key: { n1: 1, n2: 2 } }
    expect(h.except_nested_key(:n1)).to eq key: { n2: 2 }
  end
end
