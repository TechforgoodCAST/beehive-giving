require 'rails_helper'

describe Theme do
  before(:all) do
    @t1 = create(:theme)
    @t2 = create(:theme, parent: @t1)
  end

  it 'valid with parent' do
    expect(@t2).to be_valid
  end

  it 'valid without parent' do
    expect(@t1).to be_valid
  end

  it 'belongs to parent' do
    expect(@t2.parent).to eq @t1
  end

  it 'name is unique' do
    @t2.name = @t1.name
    expect(@t2).not_to be_valid
  end
end
