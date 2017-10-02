require 'rails_helper'
require 'pundit/rspec'

describe ChargePolicy do
  subject { described_class }

  before(:each) do
    @user = instance_double(User, subscribed?: false)
  end

  permissions :new?, :create? do
    it 'grants access if user unsubscribed' do
      expect(subject).to permit(@user, :charge)
    end

    it 'denies access if user subscribed' do
      allow(@user).to receive(:subscribed?).and_return(true)
      expect(subject).not_to permit(@user, :charge)
    end
  end

  permissions :thank_you? do
    it 'denies access if user unsubscribed' do
      is_expected.not_to permit(@user, :charge)
    end

    it 'grants access if user subscribed' do
      allow(@user).to receive(:subscribed?).and_return(true)
      is_expected.to permit(@user, :charge)
    end
  end
end
