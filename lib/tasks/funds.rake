namespace :funds do
  # usage: rake funds:import FILE=/path/to/file.csv
  # add: SAVE=true to save
  desc 'Add new restrictions for import task'
  task restrictions: :environment do
    [
      ['a museum or consortium', true],
      ['in a partnership or a consortium with one lead organisation', true],
      ['where the lead applicant has been Arts Council funded, or presented work to the public through one of their programmes', true],
      ['that solely concentrate on the purchasing of property, equipment or other capital items', false],
      ['where you have secured a minimum of 50% of the costs of the project', true],
      ['a hospice', true],
      ['meets the needs of children and young people in the following counties: Berkshire; Buckinghamshire; Hampshire; Isle of Wight; Kent; Oxfordshire; Surrey; East Sussex; and West Sussex', true],
      ['public library, public library authority, network of public library authorities, or an organisation managing a public library authority as defined under the Public Libraries & Museums Act 1964', true]
    ].each do |i|
      Restriction.where(
        details: i[0],
        invert: i[1]
      ).first_or_create!
    end
  end

  # usage: rake funds:import FILE=/path/to/file.csv
  # add: SAVE=true to save
  desc 'Import production data'
  task import: :environment do
    require 'open-uri'
    require 'csv'

    @errors = []
    @counters = {
      valid_funds:   0,
      invalid_funds: 0
    }

    def obj_name(obj)
      obj.class.name.downcase
    end

    def save(obj, values, last = false)
      obj.assign_attributes(values)
      obj_name = obj_name(obj)

      if obj.valid?
        print last ? '. ' : '.'
        @counters["valid_#{obj_name}s".to_sym] += 1
        obj.save if ENV['SAVE']
      else
        print last ? '* ' : '*'
        @counters["invalid_#{obj_name}s".to_sym] += 1
        @errors << "#{obj.slug}: #{obj.errors.full_messages}"
      end
    end

    def log(obj)
      obj_name = obj_name(obj)
      puts "#{obj.class.name}s: #{@counters["valid_#{obj_name}s".to_sym]} #{ENV['SAVE'] ? 'saved' : 'valid'}, #{@counters["invalid_#{obj_name}s".to_sym]} invalid"
    end

    CSV.parse(open(ENV['FILE']).read, headers: true) do |row|
      @funder = Funder.where(name: row['funder']).first
      @fund = @funder.funds
                     .where(funder: @funder, name: row['name'])
                     .first_or_initialize

      fund_values = row.to_hash.except('funder', 'valid', 'old_description', 'soft_restrictions')

      fund_values = fund_values.merge(
        'type_of_fund' => 'Grant',
        'currency' => 'GB',
        'restrictions_known' => true,
        'geographic_scale' => Proposal::AFFECT_GEO.map { |arr| arr[0] }.index(row['geographic_scale']),
        'tags' => ActsAsTaggableOn::Tag.where(slug: row['tags'].split),
        'countries' => Country.where(alpha2: row['countries'].split(', '))
      )

      fund_values['districts'] = if row['districts'] == 'all'
                                   District.where(country: fund_values['countries']).uniq
                                 else
                                   District.where(
                                     'sub_country IN (:districts) OR
                                     region IN (:districts) OR
                                     district IN (:districts)',
                                     districts: row['districts'].split(', ')
                                   )
                                 end

      if row['restriction_ids'] == 'same'
        fund_values[:restriction_ids] = @funder.funding_streams.first.restriction_ids
      else
        restrictions = row['restriction_ids'].split(' | ')

        fund_values[:restriction_ids] = if restrictions.include?('same')
                                          @funder.funding_streams.first.restriction_ids
                                        else
                                          []
                                        end

        fund_values[:restriction_ids] = (
          fund_values[:restriction_ids] +
          Restriction.where(details: restrictions).pluck(:id)
        ).uniq
      end

      save(@fund, fund_values)
    end

    puts "\n\n"
    log(@fund)
    if @errors.count.positive?
      puts "\nErrors\n------"
      puts @errors
    end
    puts "\n"
  end
end
