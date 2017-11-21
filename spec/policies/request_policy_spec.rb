require 'rails_helper'
require 'pundit/rspec'

describe RequestPolicy do
  subject { described_class }

  let(:subscribed) { false }
  let(:fund) { Fund.new(slug: 'fund') }
  let(:requests) { [] }
  let(:user) do
    instance_double(
      User,
      subscription_active?: subscribed
    )
  end
  let(:recipient) { Recipient.new() }
 
  permissions :create? do
    it 'not subscribed' do
      is_expected.not_to permit(user, :requests)
    end

    context 'subscribed' do
      let(:subscribed){ true }

      it 'permit' do
        is_expected.to permit(user, :requests)
      end
    end
  end
end
