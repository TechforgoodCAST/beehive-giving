class SignupProposal
  MAPPING = {
    'The general public' => 'Public and societal benefit',
    'Affected or involved with crime' => 'Crime and justice',
    'With family/relationship challenges' => 'Family and relationships',
    'With disabilities' => 'Disability',
    'With specific religious/spiritual beliefs' => 'People with a specific religious/spiritual beliefs',
    'Affected by disasters' => 'Disaster preparedness and relief',
    'In education' => 'Education and training',
    'Who are unemployed' => 'Employment',
    'From a specific ethnic background' => 'People from a specific ethnic background',
    'With water/sanitation access challenges' => 'Water, sanitation and public infrastructure',
    'With food access challenges' => 'Food and agriculture',
    'With housing/shelter challenges' => 'Housing and shelter',
    'Animals and wildlife' => 'Animals and wildlife',
    'Buildings and places' => 'Building and places',
    'With mental diseases or disorders' => 'Mental wellbeing, diseases and disorders',
    'With a specific sexual orientation' => 'People with a specific gender or sexual identity',
    'Climate and the environment' => 'Climate and the environment',
    'With physical diseases or disorders' => 'Physical wellbeing, diseases and disorders',
    'Organisations' => 'Organisational development',
    'Facing income poverty' => 'Poverty',
    'Who are refugees and asylum seekers' => 'Migration, refugees and asylum seekers',
    'Involved with the armed or rescue services' => 'Armed and rescue services',
    'In, leaving, or providing care' => 'People in, leaving or providing care',
    'At risk of sexual exploitation, trafficking, forced labour, or servitude' => 'Human rights and exploitation'
  }.freeze

  def initialize(organisation)
    @organisation = organisation
    @proposal = @organisation.proposals.new(
      # TODO: avoid db call
      countries: [Country.find_by(alpha2: @organisation.country)]
    )
  end

  def build_or_transfer
    return @proposal unless
      @organisation.created_at <= Date.new(2016, 4, 27) # NOTE: ensure Profile
    return @proposal unless profile_for_migration?
    @proposal.state = 'transferred'
    transfer_data!(@profiles.last)
    @proposal.valid?
    @proposal
  end

  private

    def profile_for_migration? # TODO: refactor
      @profiles = @organisation.profiles.where(state: 'complete')
      @organisation.proposals.count.zero? && @profiles.any?
    end

    def transfer_data!(profile) # TODO: refactor
      set_boolean(profile, 'People', :affect_people)

      if @proposal.affect_people?
        @proposal.gender = profile.gender
        if profile.age_groups.present?
          @proposal.age_group_ids = profile.age_group_ids
        else
          age_ids = AgeGroup.where('age_from >= ? AND age_to <= ?',
                                   get_age_segment(profile.min_age),
                                   get_age_segment(profile.max_age, 'to'))
                            .pluck(:id)
          age_ids + [AgeGroup.first.id] if age_ids.count > 7
          @proposal.age_group_ids = age_ids
        end
      end

      %w[implementations_other_required implementations_other].each do |field|
        @proposal[field] = profile[field]
      end

      @proposal.assign_attributes(
        implementation_ids: profile.implementation_ids,
        country_ids: profile.country_ids,
        district_ids: profile.district_ids,
        themes: get_themes(profile.beneficiaries)
      )
    end

    def get_themes(beneficiaries)
      Theme.where name: beneficiaries.map { |b| MAPPING[b.label] }
    end

    def set_boolean(profile, category, field)
      @proposal[field] = profile.beneficiaries.pluck(:category)
                                .include?(category)
    end

    def get_age_segment(age, type = 'from')
      result = nil
      AgeGroup.order(id: :desc).pluck(:age_from, :age_to)
              .take(7).each do |from, to|
        result = type == 'from' ? from : to if age >= from && age <= to
      end
      result
    end
end
