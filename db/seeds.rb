if Rails.env.development?
  districts_csv = Rails.root.join('lib', 'assets', 'csv', 'districts.csv')

  CSV.foreach(districts_csv, headers: true) do |row|
    country ||= Country.where(name: row[0], alpha2: row[1]).first_or_create!

    country.districts.create!(
      name: row[3],
      subdivision: row[2],
      region: row[4],
      sub_country: row[5]
    )

    print '.'
  end
  puts
end
