require 'rails_helper'

describe Assessment do
  def assoc(model, relationship)
    expect(subject.class.reflect_on_association(model).macro).to eq relationship
  end

  it('belongs to funder') { assoc(:funder, :belongs_to) }

  it('belongs to recipient') { assoc(:recipient, :belongs_to) }

  it('belongs to proposal') { assoc(:proposal, :belongs_to) }

  it '#state in list' do
    subject.state = nil
    is_expected.not_to be_valid
  end
end
