require 'rails_helper'
require 'pundit/rspec'

describe RevealPolicy do
  subject { described_class }

  let(:reveals) { [] }
  let(:user) { instance_double(User, reveals: reveals) }

  permissions :create? do
    context 'over limit' do
      let(:reveals) { [1, 2, 3] }

      it 'denies' do
        is_expected.not_to permit(user, :reveal)
      end
    end

    it 'grants if within limit' do
      is_expected.to permit(user, :reveal)
    end
  end
end
