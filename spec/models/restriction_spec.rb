require 'rails_helper'

describe 'Restriction' do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 2)
    @db = @app.instances
    @r1 = Restriction.first
    @r2 = Restriction.last
  end

  it 'category in range' do
    expect(@r1).to be_valid

    @r1.category = 'Recipient'
    expect(@r1).to be_valid

    @r1.category = ''
    expect(@r1).not_to be_valid
  end

  it 'has_condition required' do
    @r1.has_condition = nil
    expect(@r1).not_to be_valid
  end

  it 'condition required if has_condition' do
    @r1.has_condition = true
    expect(@r1).not_to be_valid

    @r1.condition = 'some condition'
    expect(@r1).to be_valid
  end

  it 'details required' do
    @r1.details = ''
    expect(@r1).not_to be_valid
  end

  it 'details are unique' do
    @r2.details = @r1.details
    expect(@r2).not_to be_valid
  end

  it 'has many funds' do
    expect(@r1.funds.count).to eq 2
  end

  it 'has many funders through funds' do
    funder = create(:funder)
    Fund.last.update_column(:funder_id, funder.id)
    expect(@r1.funders.count).to eq 2
  end

  context 'with eligibilities' do
    before(:each) do
      @app.create_recipient
      @db = @app.instances
    end

    context 'for Proposal' do
      before(:each) do
        @app.subscribe_recipient
            .create_registered_proposal
            .create_complete_proposal
        Proposal.all.each do |proposal|
          create(:eligibility, restriction: @r2,
                               category: proposal)
        end
      end

      it 'has many eligibilities' do
        expect(@r2.eligibilities.count).to eq 2
      end
    end

    context 'for Recipient' do
      before(:each) do
        [@db[:recipient], create(:recipient)].each do |recipient|
          create(:eligibility, restriction: @r1,
                               category: recipient)
        end
      end

      it 'has many eligibilities' do
        expect(@r1.eligibilities.count).to eq 2
      end
    end
  end

  it 'invert defaults to false' do
    expect(@r1.invert).to eq false
  end

  it 'invert false returns correct radio_buttons' do
    expect(Restriction.radio_buttons(@r1.invert))
      .to eq [['Yes', false], ['No', true]]
  end

  it 'invert true returns correct radio_buttons' do
    @r1.update(invert: true)
    expect(Restriction.radio_buttons(@r1.invert))
      .to eq [['Yes', true], ['No', false]]
  end
end
