class TestHelper
  include FactoryGirl::Syntax::Methods
  include ShowMeTheCookies
  include WebMock::API

  ENV['BEEHIVE_DATA_TOKEN'] = 'token'
  ENV['BEEHIVE_DATA_FUND_SUMMARY_ENDPOINT'] = 'http://localhost/v1/integrations/fund_summary'
  ENV['BEEHIVE_INSIGHT_ENDPOINT'] = 'http://localhost/beneficiaries'
  ENV['BEEHIVE_INSIGHT_AMOUNTS_ENDPOINT'] = 'http://localhost/check_amount'
  ENV['BEEHIVE_INSIGHT_DURATIONS_ENDPOINT'] = 'http://localhost/check_duration'
  ENV['BEEHIVE_INSIGHT_TOKEN'] = 'username'
  ENV['BEEHIVE_INSIGHT_SECRET'] = 'password'

  def seed_test_db
    @age_groups      = create_list(:age_group, AgeGroup::AGE_GROUPS.count)
    @beneficiaries   = create_list(:beneficiary, Beneficiary::BENEFICIARIES.count)
    @all_ages        = @age_groups.first
    @countries       = create_list(:country, 2)
    @uk              = @countries.first
    @kenya           = @countries.last
    @uk_districts    = create_list(:district, 3, country: @uk)
    @kenya_districts = create_list(:kenya_district, 3, country: @kenya)
    @districts       = @uk_districts + @kenya_districts
    @implementations = create_list(:implementation, Implementation::IMPLEMENTATIONS.count)
    @themes          = create_list(:theme, 3)
    self
  end

  def setup_funds(num: 1, save: true, open_data: false, opts: {}) # TODO: refactor
    FactoryGirl.reload
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
      stub_fund_summary_endpoint(fund.instance_eval { set_slug })

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
    FactoryGirl.reload
    @funder = create(:funder)
    @fund_stubs = build_list(:fundstub, num, opts.merge(funder: @funder))
    @fund_stubs.each_with_index do |fund, i|
      stub_fund_summary_endpoint(fund.instance_eval { set_slug })
      fund.themes = @themes
      fund.geo_area = GeoArea.first
      fund = FundStub.new(fund: fund)
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

  def stub_beehive_insight(endpoint, data)
    body = {}
    # TODO: match records in seeds
    7.times { |i| body["funder-awards-for-all-#{i + 1}"] = (i + 1).to_f / 10 }
    stub_request(:post, endpoint).with(
      body: { data: data }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN']
      }
    ).to_return(
      status: 200,
      body: body.to_json
    )
    self
  end

  def stub_beneficiaries_endpoint
    data = Beneficiary::BENEFICIARIES.map { |i| [i[:sort], 0] }.to_h
    stub_beehive_insight(ENV['BEEHIVE_INSIGHT_ENDPOINT'], data)
    self
  end

  def stub_amounts_endpoint(data = 10_000.0)
    stub_beehive_insight(
      ENV['BEEHIVE_INSIGHT_AMOUNTS_ENDPOINT'],
      amount: data
    )
    self
  end

  def stub_durations_endpoint(data = 12)
    stub_beehive_insight(
      ENV['BEEHIVE_INSIGHT_DURATIONS_ENDPOINT'],
      duration: data
    )
    self
  end

  def stub_fund_summary_endpoint(fund_slug)
    stub_request(:get, ENV['BEEHIVE_DATA_FUND_SUMMARY_ENDPOINT'] + fund_slug)
      .with(headers: { 'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN'] })
      .to_return(status: 200, body: '', headers: {})
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

  def create_recipient_with_subscription_v1!
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

  def build_initial_proposal
    @initial_proposal = build(:initial_proposal, recipient: @recipient,
                                                 countries: [@uk],
                                                 districts: @uk_districts,
                                                 age_groups: @age_groups,
                                                 themes: @themes)
    self
  end

  def create_initial_proposal
    build_initial_proposal
    @initial_proposal.save
    self
  end

  def build_registered_proposal
    @registered_proposal = build(:registered_proposal, recipient: @recipient,
                                                       countries: [@uk],
                                                       districts: @uk_districts,
                                                       age_groups: @age_groups,
                                                       implementations: @implementations,
                                                       themes: @themes)
    self
  end

  def create_registered_proposal
    build_registered_proposal
    @registered_proposal.save
    self
  end

  def build_complete_proposal
    @complete_proposal = build(:proposal, recipient: @recipient,
                                          countries: [@uk],
                                          districts: @uk_districts,
                                          age_groups: @age_groups,
                                          implementations: @implementations,
                                          themes: @themes)
    self
  end

  def create_complete_proposal
    build_complete_proposal
    @complete_proposal.save
    self
  end

  def subscribed
    @recipient.subscribe!
    self
  end

  def instances
    instances = {
      age_groups: @age_groups,
      beneficiaries: @beneficiaries,
      all_ages: @all_ages,
      countries: @countries,
      uk: @uk,
      kenya: @kenya,
      uk_districts: @uk_districts,
      kenya_districts: @kenya_districts,
      districts: @districts,
      implementations: @implementations,
      recipient: @recipient,
      user: @user,
      initial_proposal: @initial_proposal,
      registered_proposal: @registered_proposal,
      complete_proposal: @complete_proposal,
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
