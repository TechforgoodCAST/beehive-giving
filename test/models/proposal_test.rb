require 'test_helper'

class ProposalTest < ActiveSupport::TestCase
  setup do
    seed_test_db
    @recipient = create(:recipient)
    @initial_proposal    = build(:initial_proposal, recipient: @recipient,
                                  countries: [@countries.first],
                                  districts: @uk_districts,
                                  age_groups: @age_groups,
                                  beneficiaries: @beneficiaries
                                )
    @registered_proposal = build(:registered_proposal, recipient: @recipient,
                                  countries: [@countries.first],
                                  districts: @uk_districts,
                                  age_groups: @age_groups,
                                  beneficiaries: @beneficiaries

                                )
    @proposal            = build(:proposal, recipient: @recipient,
                                  countries: [@countries.first],
                                  districts: @uk_districts,
                                  age_groups: @age_groups,
                                  beneficiaries: @beneficiaries
                                )
  end

  test 'a recipient can have many proposals' do
    @initial_proposal.save!
    @registered_proposal.save!
    @proposal.save!
    assert_equal 3, @recipient.proposals.count
  end
end
