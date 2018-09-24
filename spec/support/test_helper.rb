class TestHelper # TODO: refactor
  include FactoryBot::Syntax::Methods
  include ShowMeTheCookies
  include WebMock::API

  def seed_db
    create_list(:age_group, AgeGroup::AGE_GROUPS.count)
  end

  def seed_test_db
    @age_groups      = AgeGroup.any? ? AgeGroup.all : seed_db
    @all_ages        = @age_groups.first
    @countries       = create_list(:country, 2)
    @uk              = @countries.first
    @kenya           = @countries.last
    @uk_districts    = create_list(:district, 3, country: @uk)
    @kenya_districts = create_list(:kenya_district, 3, country: @kenya)
    @districts       = @uk_districts + @kenya_districts
    @themes          = create_list(:theme, 3)
    self
  end

  def setup_funds(num: 1, save: true, open_data: false, opts: {}) # TODO: refactor
    FactoryBot.reload
    @funder = create(:funder)
    @funds = if open_data
               build_list(:fund_with_open_data, num, opts.merge(funder: @funder))
             else
               build_list(:fund, num, opts.merge(funder: @funder))
             end
    recipient_restrictions = create_list(:recipient_restriction, 2)
    proposal_restrictions = create_list(:restriction, 5)
    @restrictions = recipient_restrictions + proposal_restrictions
    recipient_priorities = create_list(:recipient_priority, 2)
    proposal_priorities = create_list(:priority, 5)
    @priorities = recipient_priorities + proposal_priorities
    @funds.each_with_index do |fund, i|
      fund.themes = @themes

      fund.geo_area = create(:geo_area, countries: @countries, districts: (fund.geographic_scale_limited ? @uk_districts + @kenya_districts : []))

      fund.restrictions = (i.even? ? recipient_restrictions + proposal_restrictions.first(3) : recipient_restrictions + proposal_restrictions.last(3))
      fund.priorities = (i.even? ? recipient_priorities + proposal_priorities.first(3) : recipient_priorities + proposal_priorities.last(3))
      fund.save! if save
      fund.questions.where(criterion_type: "Priority").update(group: "test_group")
    end
    self
  end

  def setup_fund_stubs(num: 1, save: true, opts: {})
    FactoryBot.reload
    @funder = create(:funder, name: 'Fund Stub Funder')
    @fund_stubs = build_list(:fundstub, num, opts.merge(funder: @funder))
    @fund_stubs.each_with_index do |fund, i|
      fund.themes = @themes
      fund.geo_area = GeoArea.first
      fund.save if save
    end
    self
  end

  def create_simple_fund(num: 1)
    opts = {
      themes: create_list(:theme, 3),
      geo_area: create(:geo_area, countries: create_list(:country, 2)),
      restrictions: create_list(:recipient_restriction, 2) +
                    create_list(:restriction, 5),
      priorities: create_list(:recipient_priority, 2) +
                  create_list(:priority, 5)
    }

    funds = create_list :fund, num, opts
    funds.each{|f| f.questions.where(criterion_type: "Priority").update(group: "test_group")}
  end

  def stub_mixpanel
    stub_request(:any, 'https://api.mixpanel.com/track')
    stub_request(:any, "https://api.mixpanel.com/engage")
    self
  end

  def create_admin(opts = {})
    create(:admin_user, opts)
    self
  end

  def create_recipient(opts = {})
    options = opts.merge created_at: Date.new(2000, 1, 1) # Price A/B test
    @recipient = create(:recipient, options)
    @recipient.reload
    self
  end

  def create_recipient_with_subscription_v1! # TODO: deprecated
    create_recipient
    @recipient.subscription.update(version: 1)
    self
  end

  def subscribe_recipient
    @recipient.subscribe!
    self
  end

  def with_user(opts = { organisation_id: @recipient&.id })
    @user = create(:user, opts)
    self
  end

  def sign_in2(user)
    create_cookie(:auth_token, user.auth_token)
    self
  end

  def sign_in
    create_cookie(:auth_token, @user.auth_token)
    self
  end

  def sign_out
    expire_cookies
    self
  end

  def build_proposal
    @proposal = build(
      :proposal,
      recipient: @recipient,
      countries: [@uk],
      districts: @uk_districts,
      themes: @themes
    )
    self
  end

  def create_proposal
    build_proposal
    @proposal.save
    self
  end

  def subscribed
    @recipient.subscribe!
    self
  end

  def instances
    instances = {
      age_groups: @age_groups,
      all_ages: @all_ages,
      countries: @countries,
      uk: @uk,
      kenya: @kenya,
      uk_districts: @uk_districts,
      kenya_districts: @kenya_districts,
      districts: @districts,
      recipient: @recipient,
      user: @user,
      proposal: @proposal,
      themes: @themes
    }
    if @funds
      instances[:funds] = @funds
      instances[:funder] = @funder
      instances[:fund_stubs] = @fund_stubs
    end
    instances
  end
end
