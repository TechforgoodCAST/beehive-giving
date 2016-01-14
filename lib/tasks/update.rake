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
    Recipient.joins(:users).where(postal_code: nil).each do |r|
      puts r.name
      r.update_attribute(:status, 'Active - currently operational') if r.status.nil?

      if r.charity_number.present? && r.company_number.present?
        r.org_type = 3
      elsif r.charity_number.present? && !r.company_number.present?
        r.org_type = 1
        r.get_charity_data
        # r.set_slug
        r.save if r.get_charity_data
      elsif !r.charity_number.present? && r.company_number.present?
        r.org_type = 2
        r.get_company_data
        # r.set_slug
        r.save if r.get_company_data
      end
    end
  end

end
