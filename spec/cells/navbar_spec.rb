require 'rails_helper'

describe NavbarCell do
  controller ApplicationController

  subject { cell(:navbar, current_user).call(:show) }

  context 'logged out' do
    let(:current_user) { nil }

    it { is_expected.to have_link('About') }
    it { is_expected.to have_link('Funds') }
    it { is_expected.to have_link('Sign in') }
  end

  context 'logged in' do
    let(:current_user) { instance_double(User, organisation: true) }

    it { is_expected.to have_link('Dashboard') }
    it { is_expected.to have_link('Funds') }
    it { is_expected.to have_link('Sign out') }
  end
end
