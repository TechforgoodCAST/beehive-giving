require 'rails_helper'

describe SignupProposal do
  before(:each) do
    @app.seed_test_db.create_recipient.with_user
    @db = @app.instances
    @recipient = @db[:recipient]
  end

  it 'requires Recipient to initialize' do
    expect { SignupProposal.new }.to raise_error(ArgumentError)
  end

  it '#proposal requires Recipient with Country' do
    Country.destroy_all
    expect { SignupProposal.new(create(:recipient)) }
      .to raise_error(ActiveRecord::AssociationTypeMismatch)
  end

  it "#proposal returns 'initial' Proposal" do
    proposal = SignupProposal.new(@recipient).build_or_transfer
    expect(proposal.class).to eq Proposal
    expect(proposal.state).to eq 'initial'
  end

  context 'legacy user' do
    before(:each) do
      @legacy_recipient = build(
        :legacy_recipient, created_at: Date.new(2016, 4, 27)
      )
      @legacy_recipient.save(validate: false)
      Subscription.create(organisation_id: @legacy_recipient.id)
      @legacy_recipient.reload
      @legacy_profile = build(
        :legacy_profile,
        organisation: @legacy_recipient,
        countries: @db[:countries], districts: @db[:districts],
        age_groups: @db[:age_groups], beneficiaries: @db[:beneficiaries]
      )
      @legacy_profile.save(validate: false)
    end

    it 'legacy user triggers #transfer!' do
      proposal = SignupProposal.new(@legacy_recipient).build_or_transfer
      expect(proposal.state).to eq 'transferred'
    end

    it '#profile_for_migration?' do
      expect(
        SignupProposal.new(@legacy_recipient).send(:profile_for_migration?)
      ).to eq true
    end

    it '#transfer_data!' do
      proposal = SignupProposal.new(@legacy_recipient)
      proposal.send(:transfer_data!, @legacy_profile)
      transfered_proposal = proposal.instance_variable_get(:@proposal)
      expect(transfered_proposal.beneficiaries.size).to eq 25
      # TODO: cover all transferred fields
    end

    it '#set_boolean!' do
      proposal = SignupProposal.new(@legacy_recipient)
      { affect_people: 'People', affect_other: 'Other' }.each do |k, v|
        expect(proposal.instance_variable_get(:@proposal)[k]).to eq nil
        proposal.send(:set_boolean, @legacy_profile, v, k)
        expect(proposal.instance_variable_get(:@proposal)[k]).to eq true
      end
    end

    it '#get_age_segment' do
      proposal = SignupProposal.new(@legacy_recipient)
      min_age = proposal.send(:get_age_segment, @legacy_profile.min_age)
      max_age = proposal.send(:get_age_segment, @legacy_profile.max_age, 'to')
      expect(min_age).to eq 12
      expect(max_age).to eq 35
    end
  end
end
