require 'rails_helper'
require 'pundit/rspec'

describe EnquiryPolicy do
  subject { described_class }

  let(:subscribed) { false }
  let(:reveals) { [] }
  let(:user) do
    instance_double(User, subscription_active?: subscribed, reveals: reveals)
  end

  let(:eligibility) { ELIGIBLE }
  let(:assessment) { create(:eligible, eligibility_quiz: eligibility) }
  let(:context) { EnquiryContext.new(assessment.fund, assessment.proposal) }

  permissions :new?, :create? do
    it 'denies access if no fund supplied' do
      is_expected.not_to permit(user, context)
    end

    context 'incomplete' do
      let(:eligibility) { INCOMPLETE }
      it { is_expected.not_to permit(user, context) }
    end

    context 'ineligible' do
      let(:eligibility) { INELIGIBLE }
      it { is_expected.not_to permit(user, context) }
    end

    context 'eligible and subscribed' do
      let(:subscribed) { true }
      it { is_expected.to permit(user, context) }
    end

    context 'eligible and revealed' do
      let(:reveals) { [assessment.fund.slug] }
      it { is_expected.to permit(user, context) }
    end

    context 'fund not revealed' do
      it { is_expected.not_to permit(user, context) }
    end
  end

end
