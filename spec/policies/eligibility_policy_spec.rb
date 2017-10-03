require 'rails_helper'
require 'pundit/rspec'

describe EligibilityPolicy do
  subject { described_class }

  permissions :new?, :create? do
    let(:subscribed) { false }
    let(:funds_checked) { 3 }
    let(:fund) { Fund.new(slug: 'fund') }
    let(:proposal) { Proposal.new(eligibility: eligibility) }
    let(:eligibility) { { fund.slug => { 'quiz' => 1 }} }
    let(:eligibility_context) { EligibilityContext.new(fund, proposal) }
    let(:user) do
      instance_double(
        User,
        subscribed?: subscribed,
        organisation: Recipient.new(funds_checked: funds_checked)
      )
    end

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
end
