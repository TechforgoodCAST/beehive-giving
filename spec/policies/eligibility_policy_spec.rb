require 'rails_helper'
require 'pundit/rspec'

describe EligibilityPolicy do
  subject { described_class }

  let(:version) { 1 }

  let(:subscribed) { false }
  let(:funds_checked) { 3 }
  let(:eligibility) { { fund.slug => { 'quiz' => 1 }} }

  let(:fund) { Fund.new(slug: 'fund') }
  let(:proposal) { Proposal.new(eligibility: eligibility) }
  let(:eligibility_context) { EligibilityContext.new(fund, proposal) }
  let(:user) do
    instance_double(
      User,
      subscription_active?: subscribed,
      subscription_version: version,
      organisation: Recipient.new(funds_checked: funds_checked)
    )
  end

  context 'v1' do
    permissions :new?, :create? do
      context 'user subscribed' do
        let(:subscribed) { true }

        it 'grants access' do
          is_expected.to permit(user, eligibility_context)
        end
      end

      context 'fund checked and less than 3 funds checked' do
        let(:funds_checked) { 0 }

        it 'grants access' do
          is_expected.to permit(user, eligibility_context)
        end
      end

      context 'fund checked and more than 2 funds checked' do
        it 'grants access' do
          is_expected.to permit(user, eligibility_context)
        end
      end

      context 'fund unchecked and less than 3 funds checked' do
        let(:eligibility) { {} }
        let(:funds_checked) { 0 }

        it 'grants access' do
          is_expected.to permit(user, eligibility_context)
        end
      end

      context 'fund unchecked and more than 2 funds checked' do
        let(:eligibility) { {} }

        it 'denies access' do
          is_expected.not_to permit(user, eligibility_context)
        end
      end
    end

    permissions :edit?, :update? do
      it 'grants access if checked fund' do
        is_expected.to permit(user, eligibility_context)
      end

      context 'unchecked fund' do
        let(:eligibility) { {} }

        it 'denies access' do
          is_expected.not_to permit(user, eligibility_context)
        end
      end
    end
  end

  context 'v2' do
    let(:version) { 2 }

    permissions :new?, :create? do
      it 'grants access' do
        is_expected.to permit(user, eligibility_context)
      end
    end

    permissions :edit?, :update? do
      it 'grants access' do
        is_expected.to permit(user, eligibility_context)
      end
    end
  end
end
