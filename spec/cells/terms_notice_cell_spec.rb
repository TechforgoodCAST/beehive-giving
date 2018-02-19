require 'rails_helper'

describe TermsNotice do
  controller ApplicationController

  subject { cell(:terms_notice, user).call(:show) }

  let(:user) { build(:user, id: 1) }

  context 'outdated agreement' do
    it { is_expected.to have_text('Your rights') }
  end

  context 'logged out' do
    let(:user) { nil }
    it { is_expected.not_to have_text('Your rights') }
  end

  context 'already agreed' do
    let(:user) { build(:user, id: 1, terms_version: TERMS_VERSION) }
    it { is_expected.not_to have_text('Your rights') }
  end
end
