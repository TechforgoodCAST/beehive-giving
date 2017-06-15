require 'rails_helper'

describe Hash do
  before(:each) do
    @h = { key: { n1: 1, n2: { n3: 3 } } }
  end

  it '#except_nested_key' do
    expect(@h.except_nested_key(:n2)).to eq key: { n1: 1 }
  end

  it '#all_values_for' do
    expect(@h.all_values_for(:n2)).to eq [{ n3: 3 }]
    expect(@h.all_values_for(:n3)).to eq [3]
    expect(@h.all_values_for(:n4)).to eq []
  end

  it '#root_all_values_for' do
    expect(@h.root_all_values_for(:n3)).to eq key: [3]
  end
end
