class TestHelper

  include FactoryGirl::Syntax::Methods
  include ShowMeTheCookies
  include WebMock::API

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

  def setup_funds(num: 1, save: true, open_data: false) # TODO: refactor
    FactoryGirl.reload
    @funder = create(:funder)
    if open_data
      @funds = build_list(:fund_with_open_data, num, funder: @funder)
    else
      @funds = build_list(:fund, num, funder: @funder)
    end
    @funding_types = create_list(:funding_type, FundingType::FUNDING_TYPE.count)
    @restrictions = create_list(:restriction, 2)
    @outcomes = create_list(:outcome, 2)
    @decision_makers = create_list(:decision_maker, 2)
    @funds.each do |fund|
      fund.deadlines = create_list(:deadline, 2, fund: fund)
      fund.stages = create_list(:stage, 2, fund: fund)
      fund.funding_types = @funding_types
      fund.countries = @countries
      fund.districts = @uk_districts + @kenya_districts
      fund.restrictions = @restrictions
      fund.outcomes = @outcomes
      fund.decision_makers = @decision_makers
    end
    @funds.each { |f| f.save! } if save
    self
  end

  def stub_beehive_insight(endpoint, data)
    stub_request(:post, endpoint).with(
      body: { data: data }.to_json,
      basic_auth: [ENV['BEEHIVE_INSIGHT_TOKEN'], ENV['BEEHIVE_INSIGHT_SECRET']],
      headers: { 'Content-Type'=>'application/json' }
    ).to_return(
      status: 200,
      body: {"2015-acme-awards-for-all-1"=>0.5}.to_json
    )
    self
  end

  def stub_beneficiaries_endpoint(categories=['People'])
    data = Beneficiary::BENEFICIARIES
            .map { |i| [i[:sort], categories.include?(i[:category]) ? 1 : 0] }.to_h
    stub_beehive_insight(ENV['BEEHIVE_INSIGHT_ENDPOINT'], data)
    self
  end

  def stub_amounts_endpoint(data=10000.0)
    stub_beehive_insight(
      ENV['BEEHIVE_INSIGHT_AMOUNTS_ENDPOINT'],
      { amount: data }
    )
    self
  end

  def stub_durations_endpoint(data=12)
    stub_beehive_insight(
      ENV['BEEHIVE_INSIGHT_DURATIONS_ENDPOINT'],
      { duration: data }
    )
    self
  end

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
    return instances
  end

end
