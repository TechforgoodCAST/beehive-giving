require 'rails_helper'
require 'pundit/rspec'

describe ChargePolicy do
  subject { described_class }

  permissions :new?, :create? do
    it 'grants access if `record` public' do
      record = build(:proposal)
      is_expected.to permit(nil, record)
    end

    it 'denies access if `record` missing' do
      is_expected.not_to permit(nil, nil)
    end

    it 'denies access `record` private' do
      record = build(:proposal, private: Time.zone.now)
      is_expected.not_to permit(nil, record)
    end
  end
end
