class RecipientHelper

  include FactoryGirl::Syntax::Methods
  include ShowMeTheCookies

  def create_recipient
    @recipient = create(:recipient)
    @recipient.reload
    self
  end

  def with_user
    @user = create(:user, organisation: @recipient)
    self
  end

  def sign_in
    create_cookie(:auth_token, @user.auth_token)
    self
  end

  def registered_proposal
    @proposal = create(:registered_proposal,
                        recipient: @recipient,
                        countries: Country.all,
                        districts: District.all
                      )
    self
  end

  def subscribed
    @recipient.subscribe!
    self
  end

  def instances
    return {
      recipient: @recipient,
      user: @user,
      proposal: @proposal,
      subscription: @recipient.subscription
    }
  end

end
