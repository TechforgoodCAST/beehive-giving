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
    @age_groups           = create_list(:age_group, AgeGroup::AGE_GROUPS.count)
    @all_ages             = @age_groups.first
    @beneficiaries        = create_list(:beneficiary, Beneficiary::BENEFICIARIES.count)
    @beneficiaries_people = Beneficiary.people
    @beneficiaries_other  = Beneficiary.other
    @countries            = create_list(:country, 2)
    @uk                   = @countries.first
    @kenya                = @countries.last
    @uk_districts         = create_list(:district, 3, country: @uk)
    @kenya_districts      = create_list(:kenya_district, 3, country: @kenya)
    @districts            = @uk_districts + @kenya_districts
    @implementations      = create_list(:implementation, Implementation::IMPLEMENTATIONS.count)
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
    @funding_types = create_list(:funding_type, FundingType::FUNDING_TYPE.count)
    recipient_restrictions = create_list(:recipient_restriction, 2)
    proposal_restrictions = create_list(:restriction, 5)
    @restrictions = recipient_restrictions + proposal_restrictions
    @outcomes = create_list(:outcome, 2)
    @decision_makers = create_list(:decision_maker, 2)
    @funds.each_with_index do |fund, i|
      stub_fund_summary_endpoint(fund.instance_eval { set_slug })

      fund.deadlines = create_list(:deadline, 2, fund: fund)
      fund.stages = build_list(:stage, 2, fund: fund)
      fund.funding_types = @funding_types
      fund.countries = @countries
      fund.districts = @uk_districts + @kenya_districts if fund.geographic_scale_limited
      fund.restrictions = (i.even? ? recipient_restrictions + proposal_restrictions.first(3) : recipient_restrictions + proposal_restrictions.last(3))
      fund.outcomes = @outcomes
      fund.decision_makers = @decision_makers
      fund.save! if save
    end
    self
  end

  def tag_funds
    Fund.all.each do |fund|
      fund.tags += ['Arts']
      fund.save
    end
    self
  end

  def deprecated_funders_setup
    create(:funder_attribute, funder: @funder, countries: [@uk], districts: @uk_districts)
    create_list(:grant, 3, funder: @funder, countries: [@uk], districts: @uk_districts)
    @funder.update_current_attribute
    self
  end

  def stub_beehive_insight(endpoint, data)
    body = {}
    # TODO: match records in seeds
    7.times { |i| body["acme-awards-for-all-#{i + 1}"] = (i + 1).to_f / 10 }
    stub_request(:post, endpoint).with(
      body: { data: data }.to_json,
      basic_auth: [ENV['BEEHIVE_INSIGHT_TOKEN'], ENV['BEEHIVE_INSIGHT_SECRET']],
      headers: { 'Content-Type' => 'application/json' }
    ).to_return(
      status: 200,
      body: body.to_json
    )
    self
  end

  def stub_beneficiaries_endpoint(categories = ['People'])
    data = Beneficiary::BENEFICIARIES
           .map { |i| [i[:sort], categories.include?(i[:category]) ? 1 : 0] }.to_h
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
    @recipient = create(:recipient, opts)
    @recipient.reload
    self
  end

  def subscribe_recipient
    @recipient.subscribe!
    self
  end

  def with_user(opts = { organisation: @recipient })
    @user = create(:user, opts)
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
                                                 countries: [@uk], districts: @uk_districts,
                                                 age_groups: @age_groups, beneficiaries: @beneficiaries)
    self
  end

  def create_initial_proposal
    build_initial_proposal
    @initial_proposal.save
    self
  end

  def build_registered_proposal
    @registered_proposal = build(:registered_proposal, recipient: @recipient,
                                                       countries: [@uk], districts: @uk_districts,
                                                       age_groups: @age_groups, beneficiaries: @beneficiaries,
                                                       implementations: @implementations)
    self
  end

  def create_registered_proposal
    build_registered_proposal
    @registered_proposal.save
    self
  end

  def build_complete_proposal
    @complete_proposal = build(:proposal, recipient: @recipient,
                                          countries: [@uk], districts: @uk_districts,
                                          age_groups: @age_groups, beneficiaries: @beneficiaries,
                                          implementations: @implementations)
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
      all_ages: @all_ages,
      beneficiaries: @beneficiaries,
      beneficiaries_people: @beneficiaries_people,
      beneficiaries_other: @beneficiaries_other,
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
      complete_proposal: @complete_proposal
    }
    if @funds
      instances[:funds] = @funds
      instances[:funder] = @funder
    end
    instances
  end
end
