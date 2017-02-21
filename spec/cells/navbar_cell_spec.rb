require 'rails_helper'

describe NavbarCell do
  controller ApplicationController

  it 'guest can sign in' do
    guest = cell(:navbar, nil).call(:show)
    expect(guest).to have_css '.logo'
    expect(guest).to have_link 'Sign in'
  end

  it 'signup can only see logo' do
    signup = cell(:navbar, create(:user)).call(:show)
    expect(signup).to have_css '.logo'
    expect(signup).not_to have_link 'Sign in'
  end

  it 'signed up can see nav' do
    @app.seed_test_db.create_recipient.with_user.create_registered_proposal
    registered = cell(:navbar, @app.instances[:user]).call(:show)
    expect(registered).to have_css '.logo'
    expect(registered).not_to have_link 'Sign in'
    ['Funding', 'Funding proposals', 'Sign out'].each do |text|
      expect(registered).to have_link text
    end
  end
end
