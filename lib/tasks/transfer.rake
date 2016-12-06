namespace :transfer do

  # usage: be rake transfer:website
  desc 'Update recipient websites'
  task :website => :environment do
    Recipient.where('website !~ ? AND website ~ ?', 'http', 'www').each do |r|
      r.update_attribute(:website, "http://#{r.website}")
    end
    Recipient.where(website: '').each { |r| r.update_attribute(:website, nil) }
  end

  # usage: be rake transfer:england
  desc 'Update districts marked as England'
  task :england => :environment do
    District.find(11742).update_attributes( region: 'South West',
                                            sub_country: 'England')
    District.find(12093).update_attributes( region: 'West Midlands',
                                            sub_country: 'England')
  end

  # update: be rake transfer:profile_districts
  desc 'Update districts for profiles marked with sub-countries'
  task :profile_districts => :environment do

    def query(region)
      Profile.joins(:districts).where('districts.district = ?', region).count
    end

    def migrate(region)
      remove_id = [District.where(district: region).first.id]
      region_ids = District.where(region: region).pluck(:id)

      Profile.joins(:districts).where('districts.district = ?', region).each do |p|
        p.district_ids = ((p.district_ids + region_ids) - remove_id).uniq
        p.save(validate: false)
      end
    end

    def update_sub_country(region)
      District.where(region: region).each do |d|
        d.update_column(:sub_country, region)
      end
    end

    def run(region)
      if query(region) == 0
        puts query(region)
        District.where(district: region).first.destroy
      else
        migrate(region)
        update_sub_country(region) unless region == 'London'
      end
    end

    ['London', 'England', 'Wales', 'Scotland', 'Northern Ireland'].each do |region|
      run(region)
    end
  end

  # usage: be rake transfer:profiles LIMIT=50 SAVE=true
  desc 'Transfer profiles to proposals'
  task :profiles => :environment do

    Recipient.joins(:users, :profiles).where('founded_on is not null').limit(ENV['LIMIT'] || 10).each do |recipient|
      if recipient.proposals.count == 0 && recipient.profiles.where(state: 'complete').count.positive?

        profile = recipient.profiles.where(state: 'complete').last

        def set_operating_for(recipient)
          age = ((Date.today - recipient.founded_on).to_f / 365)
          if age <= 1
            recipient.operating_for = 1
          elsif age > 1 && age <= 3
            recipient.operating_for = 2
          elsif age > 3
            recipient.operating_for = 3
          end
        end

        # recipient
        set_operating_for(recipient) unless recipient.operating_for.present?
        recipient.income_select(profile.income) unless recipient.income.present?
        recipient.staff_select('employees', profile.staff_count) unless recipient.employees.present?
        recipient.staff_select('volunteers', profile.volunteer_count) unless recipient.volunteers.present?

        recipient.save(validate: false) if ENV['SAVE']

        proposal = recipient.proposals.new
        proposal.state = 'transferred'

        # beneficiaries
        proposal.gender = profile.gender

        def get_age_segment(age, type='from')
          result = nil
          AgeGroup.order(id: :desc).pluck(:age_from, :age_to).take(7).each do |from, to|
            result = type == 'from' ? from : to if age >= from && age <= to
          end
          return result
        end

        age_ids = AgeGroup.where('age_from >= ? AND age_to <= ?',
                                  get_age_segment(profile.min_age),
                                  get_age_segment(profile.max_age, 'to')).pluck(:id)
        age_ids + [AgeGroup.first.id] if age_ids.count > 7
        proposal.age_group_ids = age_ids

        people_ids = profile.beneficiaries.where(category: 'People').pluck(:id)
        other_groups_ids = profile.beneficiaries.where(category: 'Other').pluck(:id)
        people_ids.count.positive? ? proposal.affect_people = true : proposal.affect_people = false
        other_groups_ids.count.positive? ? proposal.affect_other = true : proposal.affect_other = false
        proposal.beneficiary_ids = people_ids + other_groups_ids
        proposal.beneficiaries_other_required = profile.beneficiaries_other_required
        proposal.beneficiaries_other = recipient.profiles.pluck(:beneficiaries_other)[0]

        # location
        if profile.country_ids.count > 1
          proposal.affect_geo = 3
        elsif (profile.districts.pluck(:id) & Country.find(profile.country_ids[0]).districts.pluck(:id)).count == 0
          proposal.affect_geo = 2
        elsif profile.districts.pluck(:region).uniq.count > 1
          proposal.affect_geo = 1
        else
          proposal.affect_geo = 0
        end
        proposal.country_ids = profile.country_ids
        proposal.district_ids = profile.district_ids

        proposal.save(validate: false) if ENV['SAVE']

        # refactor
        # proposal.initial_recommendation
      end
    end
  end

end
