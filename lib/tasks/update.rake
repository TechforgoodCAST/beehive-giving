namespace :update do

  # usage: be rake update:funder_attributes
  desc 'Update funder attribute insights'
  task :funder_attributes => :environment do
    FunderAttribute.where(funding_stream: 'All').find_each { |f| f.set_insights }
  end

  # usage: be rake update:eligibility
  desc 'Ensure legacy users have eligibility set on recommendations'
  task :eligibility => :environment do
    Recipient.joins(:users).find_each { |r| r.check_eligibilities }
  end

  # usage: be rake update:show_duplicates
  desc 'Show duplicate recipients'
  task :show_duplicates => :environment do
    result = []
    Recipient.select('lower(name)').group('lower(name)').having("count(*) > 1").count.each do |k, v|
      result << "Duplicates: #{Recipient.where('lower(name) = ?', k).pluck(:id).count - 1} #{Recipient.where('lower(name) = ?', k).pluck(:id)}, #{k}"
    end
    puts result
    puts "TOTAL: #{result.count}\n"
  end

  # usage: be rake update:merge_duplicates
  desc 'Merge duplicate recipients'
  task :merge_duplicates => :environment do
    arr = [""]
    Recipient.select('lower(name)').group('lower(name)').having("count(*) > 1").count.each do |k, v|
      primary_recipient = nil
      Recipient.where('lower(name) = ?', k).order(:grants_count).each do |recipient|
        if recipient.grants_count == recipient.grants.count
          if recipient.users.count > 0
            arr << "PRIMARY recipient: #{recipient.id}, Users: #{recipient.users.count}, Grants: #{recipient.grants.count}, Profiles: #{recipient.profiles.count}"
            primary_recipient = recipient
          elsif recipient.users.count == 0 && recipient.grants.count == 0
            if recipient.profiles.count == 0 && recipient.users.count == 0
              arr << "DELETED recipient #{recipient.id}, had #{recipient.users.count} users, #{recipient.grants.count} grants, and #{recipient.profiles.count} profiles"
              recipient.destroy
            else
              arr << "Did not delete recipient #{recipient.id}, #{recipient.users.count} user(s) exist, and #{recipient.profiles.count} profile(s) exist"
            end
          else
            # no recipients with users get here
            recipient.grants.each do |grant|
              grant.recipient_id = recipient.id
              if primary_recipient
                arr << "CHANGED grant #{grant.id} from recipient #{recipient.id} to #{primary_recipient.id}"
                grant.update_column(:recipient_id, primary_recipient.id)
                if recipient.profiles.count == 0 && recipient.users.count == 0
                  arr << "DELETED recipient #{recipient.id}, which had #{recipient.users.count} users, #{recipient.grants.count} grants, and #{recipient.profiles.count} profiles"
                  recipient.destroy
                end
              else
                first_grant_recipient = Recipient.find(Recipient.where('lower(name) = ?', k).order(grants_count: :desc).pluck(:id).first)
                arr << "CHANGED grant #{grant.id} from recipient #{recipient.id} to #{first_grant_recipient.id}"
                grant.update_column(:recipient_id, first_grant_recipient.id)
                if recipient.profiles.count == 0 && recipient.users.count == 0 && recipient.grants.count == 0
                  arr << "DELETED recipient #{recipient.id}, had #{recipient.users.count} users, #{recipient.grants.count} grants, and #{recipient.profiles.count} profiles"
                  recipient.destroy
                end
              end
            end
          end
        else
          old_grants_count = recipient.grants_count
          Recipient.reset_counters(recipient.id, :grants)
          new_grants_count = recipient.grants_count
          arr << "UPDATED recipient.grants_count from #{old_grants_count} to #{new_grants_count}"
        end
      end
      arr << "#{Recipient.where('lower(name) = ?', k).first.name}, #{Recipient.where('lower(name) = ?', k).first.users.count} users, #{Recipient.where('lower(name) = ?', k).first.grants.count} grants, and #{Recipient.where('lower(name) = ?', k).first.profiles.count} profiles" if Recipient.where('lower(name) = ?', k).pluck(:id).count == 1
      arr << "Duplicates: #{Recipient.where('lower(name) = ?', k).pluck(:id).count - 1} #{Recipient.where('lower(name) = ?', k).pluck(:id)}"
      arr << ""
    end
    puts arr
  end

  # usage be rake update:org_type
  desc 'Update org type field with details of charity and company registration'
  task :org_type => :environment do
    Recipient.joins(:users).each do |r|
      if r.registered == true
        if r.charity_number.present? && r.company_number.present?
          puts 'Both'
          r.update_attribute(:org_type, 3)
        elsif r.charity_number.present? && !r.company_number.present?
          puts 'Charity'
          r.update_attribute(:org_type, 1)
        elsif !r.charity_number.present? && r.company_number.present?
          puts 'Company'
          r.update_attribute(:org_type, 2)
        else
        end
      else
        puts 'Unregistered'
        r.update_attribute(:org_type, 0)
      end
    end
  end

  # usage be rake update:org_scrape
  desc 'Update org details from charity and company number scrape'
  task :org_scrape => :environment do
    # Recipient.joins(:users).order(created_at: :desc).limit(10).each do |r|
    #   sleep(0.25)
    #   puts r.name
    #   r.update_attribute(:status, 'Active - currently operational') if r.status.nil?
    #
    #   if r.charity_number.present? && r.company_number.present?
    #     r.org_type = 3
    #     r.get_charity_data
    #     r.save if r.get_charity_data && r.get_company_data
    #   elsif r.charity_number.present? && !r.company_number.present?
    #     r.org_type = 1
    #     r.get_charity_data
    #     # r.set_slug
    #     r.save if r.get_charity_data
    #   elsif !r.charity_number.present? && r.company_number.present?
    #     r.org_type = 2
    #     r.get_company_data
    #     # r.set_slug
    #     r.save if r.get_company_data
    #   end
    #
    #   if r.search_address.present?
    #     break if r.geocode == nil
    #     r.geocode
    #     r.save
    #   end
    # end
  end

end
