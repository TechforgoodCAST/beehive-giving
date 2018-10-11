require 'rails_helper'

describe Fund do
  subject { build(:fund) }

  it('belongs to Funder') { assoc(:funder, :belongs_to) } # TODO: Provider

  it('belongs to GeoArea') { assoc(:geo_area, :belongs_to) }

  it('has many Assessments') { assoc(:assessments, :has_many) }

  it('has many Countries') { assoc(:countries, :has_many, through: :geo_area) }

  it('has many Districts') { assoc(:districts, :has_many, through: :geo_area) }

  it 'has many FundThemes' do
    assoc(:fund_themes, :has_many, dependent: :destroy)
  end

  it('has many Themes') { assoc(:themes, :has_many, through: :fund_themes) }

  it('has many Questions') { assoc(:questions, :has_many) }

  it('has many Criteria') { assoc(:criteria, :has_many, through: :questions) }

  it 'has many Restrictions' do
    assoc(:restrictions, :has_many, through: :questions)
  end

  it 'has many Priorities' do
    assoc(:priorities, :has_many, through: :questions)
  end

  it { is_expected.to be_valid }

  context '#name' do
    it 'presence' do
      subject.update(name: nil)
      expect_error(:name, "can't be blank")
    end

    it 'uniqueness' do
      subject.save!
      clone = subject.dup
      clone.valid?
      expect_error(:name, 'has already been taken', clone)
    end

    it 'unique to parent' do
      subject.save!
      expect(build(:fund, name: subject.name)).to be_valid
    end
  end

  context '#description' do
    it 'presence' do
      subject.update(description: nil)
      expect_error(:description, "can't be blank")
    end
  end

  context '#website' do
    it 'format' do
      subject.update(website: nil)
      msg = 'enter a valid website address e.g. http://www.example.com'
      expect_error(:website, msg)
    end
  end

  context '#state' do
    it 'default' do
      expect(subject.state).to eq('draft')
    end

    it 'in list' do
      subject.update(state: 'missing')
      expect_error(:state, 'is not included in the list')
    end
  end

  context '#themes' do
    it 'presence' do
      subject.update(themes: [])
      expect_error(:themes, "can't be blank")
    end
  end

  context '#links' do
    it 'format' do
      subject.update(links: { 'Name' => 'www.bad.link' })
      expect_error(:links, 'www.bad.link must begin with http:// or https://')
    end
  end

  context do
    subject { build(:fund_with_rules) }

    it { is_expected.to be_valid }

    context 'validate integer rules' do
      let(:rules) do
        %i[
          proposal_max_amount
          proposal_max_duration
          proposal_min_amount
          proposal_min_duration
          recipient_max_income
          recipient_min_income
        ]
      end

      it 'optional' do
        rules.each do |column|
          subject.update("#{column}": nil)
          expect(subject.errors[column]).to eq([])
        end
      end

      it 'integer' do
        rules.each do |column|
          subject.update("#{column}": 'one')
          expect_error(column, 'is not a number')
        end
      end
    end

    context 'validate array rules' do
      let(:rules) do
        %i[
          proposal_categories
          proposal_permitted_geographic_scales
          recipient_categories
        ]
      end

      it 'optional' do
        rules.each do |column|
          subject.update("#{column}": [])
          expect(subject.errors[column]).to eq([])
        end
      end

      it 'in list' do
        rules.each do |column|
          subject.update("#{column}": [-1])
          expect_error(column, 'not included in list')
        end
      end
    end

    context '#proposal_all_in_area' do
      it 'in list if #proposal_area_limited' do
        subject.proposal_area_limited = true
        subject.proposal_all_in_area = nil
        subject.valid?
        expect_error(:proposal_all_in_area, 'is not included in the list')
      end

      it 'must be blank unless #proposal_area_limited' do
        subject.proposal_area_limited = nil
        subject.proposal_all_in_area = true
        subject.valid?
        expect_error(:proposal_all_in_area, 'must be blank')
      end
    end

    context '#geo_area' do
      it 'presence if #proposal_area_limited' do
        subject.proposal_area_limited = true
        subject.geo_area = nil
        subject.valid?
        expect_error(:geo_area, "can't be blank")
      end
    end
  end

  it '#guidelines'

  it 'self.active' do
    expect(Fund.active.count).to eq(0)
    subject.state = 'active'
    subject.save!
    expect(Fund.active.count).to eq(1)
  end

  # TODO: review
  it '#version' do
    subject.save!
    subject.update_column(:updated_at, DateTime.new(2018, 1, 1).in_time_zone)
    expect(Fund.version).to eq(46947589)
  end

  # TODO: review
  context '#assessment' do
    it 'missing' do
      expect(subject.assessment).to eq(nil)
    end

    it 'returns OpenStruct for view' do
      assessment = create(:assessment, fund: create(:fund))
      funds = Fund.join(assessment.proposal).select_view_columns
      result = OpenStruct.new(
        id: assessment.id,
        fund_id: assessment.fund.hashid,
        proposal_id: assessment.proposal_id,
        eligibility_status: assessment.eligibility_status,
        revealed: nil
      )

      expect(funds.first.assessment).to eq(result)
    end
  end
end
