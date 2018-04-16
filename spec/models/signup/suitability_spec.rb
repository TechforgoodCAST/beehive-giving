require 'rails_helper'
require_relative '../../support/match_helper'

describe Signup::Suitability do
  subject { described_class.new(basics, params) }

  let(:helper) { MatchHelper.new }
  let(:basics) { build(:signup_basics) }
  let(:params) { {} }

  context '#initialize' do
    it 'with wrong object' do
      expect { described_class.new({}) }
        .to raise_error(ArgumentError, 'Invalid Signup::Basics object')
    end

    it 'with invalid object' do
      expect { described_class.new(Signup::Basics.new) }
        .to raise_error(ArgumentError, 'Invalid Signup::Basics object')
    end

    context 'Recipient' do
      let(:params) { { recipient: { employees: 1 } } }

      it { expect(subject.recipient).to be_an(Recipient) }

      it 'with basics' do
        expect(subject.recipient.country).to eq('GB')
      end

      it 'with params' do
        expect(subject.recipient.employees).to eq(1)
      end

      context 'lookup' do
        before { helper.stub_charity_commission.stub_companies_house }

        let(:basics) do
          build(:signup_basics, org_type: 1, charity_number: '1161998')
        end

        it 'with reg numbers' do
          expect(subject.recipient.company_number).to eq('09544506')
        end

        context 'existing Recipient' do
          before do
            reg_nos = { charity_number: '1161998', company_number: '09544506' }
            create(:recipient, reg_nos)
          end

          it { expect(subject.recipient.persisted?).to eq(true) }
          it { expect(subject.recipient_registered).to eq(false) }

          context 'with valid User' do
            let(:params) do
              {
                user: {
                  agree_to_terms: true,
                  email: 'j.doe@example.com',
                  first_name: 'J',
                  last_name: 'Doe',
                  password: 'Pa55word'
                }
              }
            end
            before { create(:admin_user) }
            it { expect(subject.recipient_registered).to eq(true) }
          end
        end
      end
    end

    context 'Proposal' do
      let(:params) { { proposal: { total_costs: 10_000 } } }

      it { expect(subject.proposal).to be_an(Proposal) }

      it 'with basics' do
        expect(subject.proposal.funding_type).to eq(FUNDING_TYPES[1][1])
      end

      it 'with params' do
        expect(subject.proposal.total_costs).to eq(10_000)
      end

      context do
        before do
          create(:country, alpha2: 'GB')
          create(:theme, id: 1)
        end

        it 'belonging to Recipient' do
          expect(subject.proposal.recipient).to eq(subject.recipient)
        end

        it 'with countries' do
          expect(subject.proposal.countries.first).to be_a(Country)
        end
        it 'with themes' do
          expect(subject.proposal.themes.first).to be_a(Theme)
        end
      end
    end

    context 'User' do
      let(:params) { { user: { first_name: 'J' } } }

      it { expect(subject.user).to be_an(User) }

      it 'with form params' do
        expect(subject.user.first_name).to eq('J')
      end

      it 'belonging to Recipient' do
        expect(subject.recipient.users).to include(subject.user)
      end

      it '#terms_version set' do
        expect(subject.user.terms_version).to eq(TERMS_VERSION)
      end
    end
  end

  it 'does not #save when any children invalid' do
    expect(subject.save).to eq(false)
  end

  context 'all children valid' do
    before do
      create(:country, alpha2: 'GB')
      create(:theme, id: 1)
    end

    let(:params) do
      {
        recipient: {
          employees: 1,
          income_band: 1,
          name: 'Recipient Name',
          operating_for: 1,
          street_address: 'London Road',
          volunteers: 1
        },
        proposal: {
          affect_geo: 2, # An entire country
          all_funding_required: true,
          funding_duration: 12,
          private: false,
          tagline: 'Desciption of project.',
          title: 'Project Name',
          total_costs: 10_000
        },
        user: {
          agree_to_terms: true,
          email: 'j.doe@example.com',
          first_name: 'J',
          last_name: 'Doe',
          password: 'Pa55word'
        }
      }
    end

    it { expect(subject.save).to eq(true) }

    context '#save' do
      before { subject.save }
      it { expect(subject.recipient).to be_persisted }
      it { expect(subject.proposal).to be_persisted }
      it { expect(subject.user).to be_persisted }
    end

    it { expect(subject.country).to be_a(Country) }
  end

  it { expect(subject.country).to be(nil) }
end
