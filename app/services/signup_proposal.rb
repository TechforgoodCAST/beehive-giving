class SignupProposal
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
      set_boolean(profile, 'Other', :affect_other)

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

      %w(
        beneficiaries_other_required
        beneficiaries_other
        implementations_other_required
        implementations_other
      ).each do |field|
        @proposal[field] = profile[field]
      end
      @proposal.affect_other = true if @proposal.beneficiaries_other_required?

      @proposal.assign_attributes(
        beneficiary_ids: profile.beneficiary_ids,
        implementation_ids: profile.implementation_ids,
        country_ids: profile.country_ids,
        district_ids: profile.district_ids
      )
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
