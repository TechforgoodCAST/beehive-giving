class TransferProfilesToProposals < ActiveRecord::Migration[5.1]
  def up
    Proposal.skip_callback(:save, :after, :initial_recommendation)

    Profile.find_each do |profile|
      proposal = profile.organisation.proposals.new

      set_boolean(profile, proposal, 'People', :affect_people)

      if proposal.affect_people?
        proposal.gender = profile.gender
        if profile.age_groups.present?
          proposal.age_group_ids = profile.age_group_ids
        else
          age_ids = AgeGroup.where('age_from >= ? AND age_to <= ?',
                                   get_age_segment(profile.min_age),
                                   get_age_segment(profile.max_age, 'to'))
                            .pluck(:id)
          age_ids + [AgeGroup.first.id] if age_ids.count > 7
          proposal.age_group_ids = age_ids
        end
      end

      %w[implementations_other_required implementations_other].each do |field|
        proposal[field] = profile[field]
      end

      proposal.assign_attributes(
        implementation_ids: profile.implementation_ids,
        country_ids: profile.country_ids,
        district_ids: profile.district_ids,
        themes: get_themes(profile.beneficiaries)
      )

      proposal.save!(validate: false)
      profile.destroy
      print '.'
    end
    puts "\n"
  end

  def get_themes(beneficiaries)
    Theme.where name: beneficiaries.map { |b| SignupProposal::MAPPING[b.label] }
  end

  def set_boolean(profile, proposal, category, field)
    proposal[field] = profile.beneficiaries.pluck(:category)
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
