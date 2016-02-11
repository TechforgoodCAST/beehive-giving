namespace :import do
  # usage: be rake import:countries
  desc "Import countries data from file"
  task :countries => :environment do

    require 'csv'

    @messages = []
    @filename = Rails.root.join('app', 'assets', 'csv', 'countries.csv')

    if ENV['SAVE']
      Country.destroy_all
      District.destroy_all

      Country.create(name: "Afghanistan",	alpha2: "AF")
      Country.create(name: "Aland Islands",	alpha2: "AX")
      Country.create(name: "Albania",	alpha2: "AL")
      Country.create(name: "Algeria",	alpha2: "DZ")
      Country.create(name: "American Samoa",	alpha2: "AS")
      Country.create(name: "Andorra",	alpha2: "AD")
      Country.create(name: "Angola",	alpha2: "AO")
      Country.create(name: "Anguilla",	alpha2: "AI")
      Country.create(name: "Antarctica",	alpha2: "AQ")
      Country.create(name: "Antigua and Barbuda",	alpha2: "AG")
      Country.create(name: "Argentina",	alpha2: "AR")
      Country.create(name: "Armenia",	alpha2: "AM")
      Country.create(name: "Aruba",	alpha2: "AW")
      Country.create(name: "Australia",	alpha2: "AU")
      Country.create(name: "Austria",	alpha2: "AT")
      Country.create(name: "Azerbaijan",	alpha2: "AZ")
      Country.create(name: "Bahamas",	alpha2: "BS")
      Country.create(name: "Bahrain",	alpha2: "BH")
      Country.create(name: "Bangladesh",	alpha2: "BD")
      Country.create(name: "Barbados",	alpha2: "BB")
      Country.create(name: "Belarus",	alpha2: "BY")
      Country.create(name: "Belgium",	alpha2: "BE")
      Country.create(name: "Belize",	alpha2: "BZ")
      Country.create(name: "Benin",	alpha2: "BJ")
      Country.create(name: "Bermuda",	alpha2: "BM")
      Country.create(name: "Bhutan",	alpha2: "BT")
      Country.create(name: "Bolivia",	alpha2: "BO")
      Country.create(name: "Bosnia and Herzegovina",	alpha2: "BA")
      Country.create(name: "Botswana",	alpha2: "BW")
      Country.create(name: "Bouvet Island",	alpha2: "BV")
      Country.create(name: "Brazil",	alpha2: "BR")
      Country.create(name: "British Indian Ocean Territory",	alpha2: "IO")
      Country.create(name: "Brunei Darussalam",	alpha2: "BN")
      Country.create(name: "Bulgaria",	alpha2: "BG")
      Country.create(name: "Burkina Faso",	alpha2: "BF")
      Country.create(name: "Burundi",	alpha2: "BI")
      Country.create(name: "Cambodia",	alpha2: "KH")
      Country.create(name: "Cameroon",	alpha2: "CM")
      Country.create(name: "Canada",	alpha2: "CA")
      Country.create(name: "Cape Verde",	alpha2: "CV")
      Country.create(name: "Caribbean Netherlands ",	alpha2: "BQ")
      Country.create(name: "Cayman Islands",	alpha2: "KY")
      Country.create(name: "Central African Republic",	alpha2: "CF")
      Country.create(name: "Chad",	alpha2: "TD")
      Country.create(name: "Chile",	alpha2: "CL")
      Country.create(name: "China",	alpha2: "CN")
      Country.create(name: "Christmas Island",	alpha2: "CX")
      Country.create(name: "Cocos (Keeling) Islands",	alpha2: "CC")
      Country.create(name: "Colombia",	alpha2: "CO")
      Country.create(name: "Comoros",	alpha2: "KM")
      Country.create(name: "Congo",	alpha2: "CG")
      Country.create(name: "Congo, the Democratic Republic of", alpha2: "CD")
      Country.create(name: "Cook Islands",	alpha2: "CK")
      Country.create(name: "Costa Rica",	alpha2: "CR")
      Country.create(name: "Côte d'Ivoire",	alpha2: "CI")
      Country.create(name: "Croatia",	alpha2: "HR")
      Country.create(name: "Cuba",	alpha2: "CU")
      Country.create(name: "Curaçao",	alpha2: "CW")
      Country.create(name: "Cyprus",	alpha2: "CY")
      Country.create(name: "Czech Republic",	alpha2: "CZ")
      Country.create(name: "Denmark",	alpha2: "DK")
      Country.create(name: "Djibouti",	alpha2: "DJ")
      Country.create(name: "Dominica",	alpha2: "DM")
      Country.create(name: "Dominican Republic",	alpha2: "DO")
      Country.create(name: "Ecuador",	alpha2: "EC")
      Country.create(name: "Egypt",	alpha2: "EG")
      Country.create(name: "El Salvador",	alpha2: "SV")
      Country.create(name: "Equatorial Guinea",	alpha2: "GQ")
      Country.create(name: "Eritrea",	alpha2: "ER")
      Country.create(name: "Estonia",	alpha2: "EE")
      Country.create(name: "Ethiopia",	alpha2: "ET")
      Country.create(name: "Falkland Islands",	alpha2: "FK")
      Country.create(name: "Faroe Islands",	alpha2: "FO")
      Country.create(name: "Fiji",	alpha2: "FJ")
      Country.create(name: "Finland",	alpha2: "FI")
      Country.create(name: "France",	alpha2: "FR")
      Country.create(name: "French Guiana",	alpha2: "GF")
      Country.create(name: "French Polynesia",	alpha2: "PF")
      Country.create(name: "French Southern Territories",	alpha2: "TF")
      Country.create(name: "Gabon",	alpha2: "GA")
      Country.create(name: "Gambia",	alpha2: "GM")
      Country.create(name: "Georgia",	alpha2: "GE")
      Country.create(name: "Germany",	alpha2: "DE")
      Country.create(name: "Ghana",	alpha2: "GH")
      Country.create(name: "Gibraltar",	alpha2: "GI")
      Country.create(name: "Greece",	alpha2: "GR")
      Country.create(name: "Greenland",	alpha2: "GL")
      Country.create(name: "Grenada",	alpha2: "GD")
      Country.create(name: "Guadeloupe",	alpha2: "GP")
      Country.create(name: "Guam",	alpha2: "GU")
      Country.create(name: "Guatemala",	alpha2: "GT")
      Country.create(name: "Guernsey",	alpha2: "GG")
      Country.create(name: "Guinea",	alpha2: "GN")
      Country.create(name: "Guinea-Bissau",	alpha2: "GW")
      Country.create(name: "Guyana",	alpha2: "GY")
      Country.create(name: "Haiti",	alpha2: "HT")
      Country.create(name: "Heard and McDonald Islands",	alpha2: "HM")
      Country.create(name: "Honduras",	alpha2: "HN")
      Country.create(name: "Hong Kong",	alpha2: "HK")
      Country.create(name: "Hungary",	alpha2: "HU")
      Country.create(name: "Iceland",	alpha2: "IS")
      Country.create(name: "India",	alpha2: "IN")
      Country.create(name: "Indonesia",	alpha2: "ID")
      Country.create(name: "Iran",	alpha2: "IR")
      Country.create(name: "Iraq",	alpha2: "IQ")
      Country.create(name: "Ireland",	alpha2: "IE")
      Country.create(name: "Isle of Man",	alpha2: "IM")
      Country.create(name: "Israel",	alpha2: "IL")
      Country.create(name: "Italy",	alpha2: "IT")
      Country.create(name: "Jamaica",	alpha2: "JM")
      Country.create(name: "Japan",	alpha2: "JP")
      Country.create(name: "Jersey",	alpha2: "JE")
      Country.create(name: "Jordan",	alpha2: "JO")
      Country.create(name: "Kazakhstan",	alpha2: "KZ")
      Country.create(name: "Kenya",	alpha2: "KE")
      Country.create(name: "Kiribati",	alpha2: "KI")
      Country.create(name: "Kuwait",	alpha2: "KW")
      Country.create(name: "Kyrgyzstan",	alpha2: "KG")
      Country.create(name: "Lao People's Democratic Republic",	alpha2: "LA")
      Country.create(name: "Latvia",	alpha2: "LV")
      Country.create(name: "Lebanon",	alpha2: "LB")
      Country.create(name: "Lesotho",	alpha2: "LS")
      Country.create(name: "Liberia",	alpha2: "LR")
      Country.create(name: "Libya",	alpha2: "LY")
      Country.create(name: "Liechtenstein",	alpha2: "LI")
      Country.create(name: "Lithuania",	alpha2: "LT")
      Country.create(name: "Luxembourg",	alpha2: "LU")
      Country.create(name: "Macau",	alpha2: "MO")
      Country.create(name: "Macedonia",	alpha2: "MK")
      Country.create(name: "Madagascar",	alpha2: "MG")
      Country.create(name: "Malawi",	alpha2: "MW")
      Country.create(name: "Malaysia",	alpha2: "MY")
      Country.create(name: "Maldives",	alpha2: "MV")
      Country.create(name: "Mali",	alpha2: "ML")
      Country.create(name: "Malta",	alpha2: "MT")
      Country.create(name: "Marshall Islands",	alpha2: "MH")
      Country.create(name: "Martinique",	alpha2: "MQ")
      Country.create(name: "Mauritania",	alpha2: "MR")
      Country.create(name: "Mauritius",	alpha2: "MU")
      Country.create(name: "Mayotte",	alpha2: "YT")
      Country.create(name: "Mexico",	alpha2: "MX")
      Country.create(name: "Micronesi, Federated States of", alpha2: "FM")
      Country.create(name: "Moldova",	alpha2: "MD")
      Country.create(name: "Monaco",	alpha2: "MC")
      Country.create(name: "Mongolia",	alpha2: "MN")
      Country.create(name: "Montenegro",	alpha2: "ME")
      Country.create(name: "Montserrat",	alpha2: "MS")
      Country.create(name: "Morocco",	alpha2: "MA")
      Country.create(name: "Mozambique",	alpha2: "MZ")
      Country.create(name: "Myanmar",	alpha2: "MM")
      Country.create(name: "Namibia",	alpha2: "NA")
      Country.create(name: "Nauru",	alpha2: "NR")
      Country.create(name: "Nepal",	alpha2: "NP")
      Country.create(name: "New Caledonia",	alpha2: "NC")
      Country.create(name: "New Zealand",	alpha2: "NZ")
      Country.create(name: "Nicaragua",	alpha2: "NI")
      Country.create(name: "Niger",	alpha2: "NE")
      Country.create(name: "Nigeria",	alpha2: "NG")
      Country.create(name: "Niue",	alpha2: "NU")
      Country.create(name: "Norfolk Island",	alpha2: "NF")
      Country.create(name: "North Korea",	alpha2: "KP")
      Country.create(name: "Northern Mariana Islands",	alpha2: "MP")
      Country.create(name: "Norway",	alpha2: "NO")
      Country.create(name: "Oman",	alpha2: "OM")
      Country.create(name: "Pakistan",	alpha2: "PK")
      Country.create(name: "Palau",	alpha2: "PW")
      Country.create(name: "Palestine, State of", alpha2: "PS")
      Country.create(name: "Panama",	alpha2: "PA")
      Country.create(name: "Papua New Guinea",	alpha2: "PG")
      Country.create(name: "Paraguay",	alpha2: "PY")
      Country.create(name: "Peru",	alpha2: "PE")
      Country.create(name: "Philippines",	alpha2: "PH")
      Country.create(name: "Pitcairn",	alpha2: "PN")
      Country.create(name: "Poland",	alpha2: "PL")
      Country.create(name: "Portugal",	alpha2: "PT")
      Country.create(name: "Puerto Rico",	alpha2: "PR")
      Country.create(name: "Qatar",	alpha2: "QA")
      Country.create(name: "Réunion",	alpha2: "RE")
      Country.create(name: "Romania",	alpha2: "RO")
      Country.create(name: "Russian Federation",	alpha2: "RU")
      Country.create(name: "Rwanda",	alpha2: "RW")
      Country.create(name: "Saint Barthélemy",	alpha2: "BL")
      Country.create(name: "Saint Helena",	alpha2: "SH")
      Country.create(name: "Saint Kitts and Nevis",	alpha2: "KN")
      Country.create(name: "Saint Lucia",	alpha2: "LC")
      Country.create(name: "Saint Vincent and the Grenadines",	alpha2: "VC")
      Country.create(name: "Saint-Martin (France)",	alpha2: "MF")
      Country.create(name: "Samoa",	alpha2: "WS")
      Country.create(name: "San Marino",	alpha2: "SM")
      Country.create(name: "Sao Tome and Principe",	alpha2: "ST")
      Country.create(name: "Saudi Arabia",	alpha2: "SA")
      Country.create(name: "Senegal",	alpha2: "SN")
      Country.create(name: "Serbia",	alpha2: "RS")
      Country.create(name: "Seychelles",	alpha2: "SC")
      Country.create(name: "Sierra Leone",	alpha2: "SL")
      Country.create(name: "Singapore",	alpha2: "SG")
      Country.create(name: "Sint Maarten (Dutch part)",	alpha2: "SX")
      Country.create(name: "Slovakia",	alpha2: "SK")
      Country.create(name: "Slovenia",	alpha2: "SI")
      Country.create(name: "Solomon Islands",	alpha2: "SB")
      Country.create(name: "Somalia",	alpha2: "SO")
      Country.create(name: "South Africa",	alpha2: "ZA")
      Country.create(name: "South Georgia and the South Sandwich Islands",	alpha2: "GS")
      Country.create(name: "South Korea",	alpha2: "KR")
      Country.create(name: "South Sudan",	alpha2: "SS")
      Country.create(name: "Spain",	alpha2: "ES")
      Country.create(name: "Sri Lanka",	alpha2: "LK")
      Country.create(name: "St. Pierre and Miquelon",	alpha2: "PM")
      Country.create(name: "Sudan",	alpha2: "SD")
      Country.create(name: "Suriname",	alpha2: "SR")
      Country.create(name: "Svalbard and Jan Mayen Islands",	alpha2: "SJ")
      Country.create(name: "Swaziland",	alpha2: "SZ")
      Country.create(name: "Sweden",	alpha2: "SE")
      Country.create(name: "Switzerland",	alpha2: "CH")
      Country.create(name: "Syria",	alpha2: "SY")
      Country.create(name: "Taiwan",	alpha2: "TW")
      Country.create(name: "Tajikistan",	alpha2: "TJ")
      Country.create(name: "Tanzania",	alpha2: "TZ")
      Country.create(name: "Thailand",	alpha2: "TH")
      Country.create(name: "The Netherlands",	alpha2: "NL")
      Country.create(name: "Timor-Leste",	alpha2: "TL")
      Country.create(name: "Togo",	alpha2: "TG")
      Country.create(name: "Tokelau",	alpha2: "TK")
      Country.create(name: "Tonga",	alpha2: "TO")
      Country.create(name: "Trinidad and Tobago",	alpha2: "TT")
      Country.create(name: "Tunisia",	alpha2: "TN")
      Country.create(name: "Turkey",	alpha2: "TR")
      Country.create(name: "Turkmenistan",	alpha2: "TM")
      Country.create(name: "Turks and Caicos Islands",	alpha2: "TC")
      Country.create(name: "Tuvalu",	alpha2: "TV")
      Country.create(name: "Uganda",	alpha2: "UG")
      Country.create(name: "Ukraine",	alpha2: "UA")
      Country.create(name: "United Arab Emirates",	alpha2: "AE")
      Country.create(name: "United Kingdom",	alpha2: "GB")
      Country.create(name: "United States",	alpha2: "US")
      Country.create(name: "United States Minor Outlying Islands",	alpha2: "UM")
      Country.create(name: "Uruguay",	alpha2: "UY")
      Country.create(name: "Uzbekistan",	alpha2: "UZ")
      Country.create(name: "Vanuatu",	alpha2: "VU")
      Country.create(name: "Vatican",	alpha2: "VA")
      Country.create(name: "Venezuela",	alpha2: "VE")
      Country.create(name: "Vietnam",	alpha2: "VN")
      Country.create(name: "Virgin Islands (British)",	alpha2: "VG")
      Country.create(name: "Virgin Islands (U.S.)",	alpha2: "VI")
      Country.create(name: "Wallis and Futuna Islands",	alpha2: "WF")
      Country.create(name: "Western Sahara",	alpha2: "EH")
      Country.create(name: "Yemen",	alpha2: "YE")
      Country.create(name: "Zambia",	alpha2: "ZM")
      Country.create(name: "Zimbabwe",	alpha2: "ZW")
      Country.create(name: "Worldwide",	alpha2: "Worldwide")
      Country.create(name: "Other",	alpha2: "Other")
    end

    CSV.foreach(@filename, :headers => true, encoding:'iso-8859-1:utf-8') do |row|

      @country = Country.find_by_alpha2(row['alpha2']).id

      district_values = {
        :country_id => @country,
        :label => row['label'],
        :subdivision => row['subdivision'],
        :district => row['district']
      }

      district = District.new(district_values)

      if district.valid?
        district.save if ENV['SAVE']
      else
        @messages << "\n#{district.label}"
        @messages << "Grant: #{district.errors.messages}"
      end

    end

    puts @messages

  end

  desc "Import regions geometry data from file"
  # usage: be rake import:districts
  task :districts => :environment do
    require 'json'

    @filename = Rails.root.join('app', 'assets', 'csv', 'lad.json')
    file = File.read(@filename)
    data_hash = JSON.parse(file)
    data_hash.each do |obj|
      District.find_by_district(obj['name']).update_column(:geometry, obj['geometry'])
    end
  end

  desc "Generate slug for districts"
  # usage: be rake import:districts_slug
  task :districts_slug => :environment do
    District.where(country_id: 741).each do |district|
      district.update_attribute(:slug, district.district.downcase.gsub(/[^a-z0-9]+/, '-'))
    end
  end

  desc "Add indices of multiple deprivation data to districts from file"
  # usage: be rake import:imd FILE=~/filename.csv
  task :imd => :environment do
    require 'open-uri'
    require 'csv'
    @filename = ENV['FILE']
    CSV.parse(open(@filename).read, :headers => true, encoding:'iso-8859-1:utf-8') do |row|
      imd_data = {
        district: row['district'],
        indices_year: row['year'],
        indices_rank: row['rank'],
        indices_rank_proportion_most_deprived_ten_percent: row['rank_proportion'],
        indices_income_rank: row['income'],
        indices_income_proportion_most_deprived_ten_percent: row['income_proportion'],
        indices_employment_rank: row['employment'],
        indices_employment_proportion_most_deprived_ten_percent: row['employment_proportion'],
        indices_education_rank: row['education'],
        indices_education_proportion_most_deprived_ten_percent: row['education_proportion'],
        indices_health_rank: row['health'],
        indices_health_proportion_most_deprived_ten_percent: row['health_proportion'],
        indices_crime_rank: row['crime'],
        indices_crime_proportion_most_deprived_ten_percent: row['crime_proportion'],
        indices_barriers_rank: row['barriers'],
        indices_barriers_proportion_most_deprived_ten_percent: row['barriers_proportion'],
        indices_living_rank: row['living'],
        indices_living_proportion_most_deprived_ten_percent: row['living_proportion']
      }
      District.find_by_district(row['district']).update_attributes(imd_data)
    end
  end

  desc "Set regions and sub-countries for UK"
  # usage: be rake import:set_regions
  task :set_regions => :environment do
    # London
    ["City of London", "Westminster", "Kensington and Chelsea", "Hammersmith and Fulham", "Wandsworth", "Lambeth", "Southwark", "Tower Hamlets", "Hackney", "Islington", "Camden", "Brent", "Ealing", "Hounslow", "Richmond upon Thames", "Kingston upon Thames", "Merton", "Sutton", "Croydon", "Bromley", "Lewisham", "Greenwich", "Bexley", "Havering", "Barking and Dagenham", "Redbridge", "Newham", "Waltham Forest", "Haringey", "Enfield", "Barnet", "Harrow", "Hillingdon"].each do |i|
      District.find_by_district(i).update_attributes(region: 'London', sub_country: 'England')
    end

    # West Midlands
    ["Herefordshire, County of", "Shropshire", "Telford and Wrekin", "East Staffordshire", "Cannock Chase", "Lichfield", "Newcastle-under-Lyme", "South Staffordshire", "Stafford", "Staffordshire Moorlands", "Tamworth", "Stoke-on-Trent", "North Warwickshire", "Nuneaton and Bedworth", "Rugby", "Stratford-on-Avon", "Warwick", "Birmingham", "Coventry", "Dudley", "Sandwell", "Solihull", "Walsall", "Bromsgrove", "Malvern Hills", "Redditch", "Worcester", "Wychavon", "Wyre Forest"].each do |i|
      District.find_by_district(i).update_attributes(region: 'West Midlands', sub_country: 'England')
    end

    # East Midlands
    ["High Peak", "Derbyshire Dales", "South Derbyshire", "Erewash", "Amber Valley", "North East Derbyshire", "Chesterfield", "Bolsover", "Derby", "Rushcliffe", "Broxtowe", "Ashfield", "Gedling", "Newark and Sherwood", "Mansfield", "Bassetlaw", "Nottingham", "Lincoln", "North Kesteven", "South Kesteven", "South Holland", "Boston", "East Lindsey", "West Lindsey", "Charnwood", "Melton", "Harborough", "Oadby and Wigston", "Blaby", "Hinckley and Bosworth", "North West Leicestershire", "Leicester", "Rutland", "South Northamptonshire", "Northampton", "Daventry", "Wellingborough", "Kettering", "Corby", "East Northamptonshire"].each do |i|
      District.find_by_district(i).update_attributes(region: 'East Midlands', sub_country: 'England')
    end

    # Yorkshire and The Humber
    ["Sheffield", "Rotherham", "Barnsley", "Doncaster", "Wakefield", "Kirklees", "Calderdale", "Bradford", "Leeds", "Selby", "Harrogate", "Craven", "Richmondshire", "Hambleton", "Ryedale", "Scarborough", "York", "East Riding of Yorkshire", "Kingston upon Hull, City of", "North Lincolnshire", "North East Lincolnshire"].each do |i|
      District.find_by_district(i).update_attributes(region: 'Yorkshire and The Humber', sub_country: 'England')
    end

    # East of England
    ["Thurrock", "Southend-on-Sea", "Harlow", "Epping Forest", "Brentwood", "Basildon", "Castle Point", "Rochford", "Maldon", "Chelmsford", "Uttlesford", "Braintree", "Colchester", "Tendring", "Three Rivers", "Watford", "Hertsmere", "Welwyn Hatfield", "Broxbourne", "East Hertfordshire", "Stevenage", "North Hertfordshire", "St Albans", "Dacorum", "Luton", "Bedford", "Central Bedfordshire", "Cambridge", "South Cambridgeshire", "Huntingdonshire", "Fenland", "East Cambridgeshire", "Peterborough", "Norwich", "South Norfolk", "Great Yarmouth", "Broadland", "North Norfolk", "Breckland", "King's Lynn and West Norfolk", "Ipswich", "Suffolk Coastal", "Waveney", "Mid Suffolk", "Babergh", "St Edmundsbury", "Forest Heath"].each do |i|
      District.find_by_district(i).update_attributes(region: 'East of England', sub_country: 'England')
    end

    # North West
    ["Cheshire East", "Cheshire West and Chester", "Halton", "Warrington", "Barrow-in-Furness", "South Lakeland", "Copeland", "Allerdale", "Eden", "Carlisle", "Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan", "West Lancashire", "Chorley", "South Ribble", "Fylde", "Preston", "Wyre", "Lancaster", "Ribble Valley", "Pendle", "Burnley", "Rossendale", "Hyndburn", "Blackpool", "Blackburn with Darwen", "Knowsley", "Liverpool", "St. Helens", "Sefton", "Wirral"].each do |i|
      District.find_by_district(i).update_attributes(region: 'North West', sub_country: 'England')
    end

    # North East
    ["Northumberland", "Newcastle upon Tyne", "Gateshead", "North Tyneside", "South Tyneside", "Sunderland", "County Durham", "Darlington", "Hartlepool", "Stockton-on-Tees", "Redcar and Cleveland", "Middlesbrough"].each do |i|
      District.find_by_district(i).update_attributes(region: 'North East', sub_country: 'England')
    end

    # South West
    ["Bath and North East Somerset", "North Somerset", "South Somerset", "Taunton Deane", "West Somerset", "Sedgemoor", "Mendip", "South Gloucestershire", "Gloucester", "Tewkesbury", "Cheltenham", "Cotswold", "Stroud", "Forest of Dean", "Swindon", "Wiltshire", "Weymouth and Portland", "East Dorset", "North Dorset", "West Dorset", "Purbeck", "Christchurch", "Poole", "Bournemouth", "Exeter", "East Devon", "Mid Devon", "North Devon", "West Devon", "Torridge", "South Hams", "Teignbridge", "Torbay", "Plymouth", "Isles of Scilly", "Cornwall"].each do |i|
      District.find_by_district(i).update_attributes(region: 'South West', sub_country: 'England')
    end

    # South East
    ["West Berkshire", "Reading", "Wokingham", "Bracknell Forest", "Windsor and Maidenhead", "Slough", "South Bucks", "Chiltern", "Wycombe", "Aylesbury Vale", "Milton Keynes", "Hastings", "Rother", "Wealden", "Eastbourne", "Lewes", "Brighton and Hove", "Fareham", "Gosport", "Winchester", "Havant", "East Hampshire", "Hart", "Rushmoor", "Basingstoke and Deane", "Test Valley", "Eastleigh", "New Forest", "Southampton", "Portsmouth", "Isle of Wight", "Dartford", "Gravesham", "Sevenoaks", "Tonbridge and Malling", "Tunbridge Wells", "Maidstone", "Swale", "Ashford", "Shepway", "Canterbury", "Dover", "Thanet", "Medway", "Oxford", "Cherwell", "South Oxfordshire", "West Oxfordshire", "Vale of White Horse", "Spelthorne", "Runnymede", "Surrey Heath", "Woking", "Elmbridge", "Guildford", "Waverley", "Mole Valley", "Epsom and Ewell", "Reigate and Banstead", "Tandridge", "Worthing", "Arun", "Chichester", "Horsham", "Crawley", "Mid Sussex", "Adur"].each do |i|
      District.find_by_district(i).update_attributes(region: 'South East', sub_country: 'England')
    end

    # Scotland
    ["Aberdeen City", "Aberdeenshire", "Angus", "Argyll and Bute", "Clackmannanshire", "Dumfries and Galloway", "Dundee City", "East Ayrshire", "East Dunbartonshire", "East Lothian", "East Renfrewshire", "Edinburgh, City of", "Falkirk", "Fife", "Glasgow City", "Highland", "Inverclyde", "Midlothian", "Moray", "North Ayrshire", "North Lanarkshire", "Perth and Kinross", "Renfrewshire", "Scottish Borders", "South Ayrshire", "South Lanarkshire", "Stirling", "West Dunbartonshire", "West Lothian", "Eilean Siar", "Orkney Islands", "Shetland Islands"].each do |i|
      District.find_by_district(i).update_attributes(sub_country: 'Scotland')
    end

    # Wales
    ["Blaenau Gwent", "Bridgend", "Caerphilly", "Cardiff", "Carmarthenshire", "Ceredigion", "Conwy", "Denbighshire", "Flintshire", "Gwynedd", "Isle of Anglesey", "Merthyr Tydfil", "Monmouthshire", "Neath Port Talbot", "Newport", "Pembrokeshire", "Powys", "Rhondda Cynon Taf", "Swansea", "Torfaen", "The Vale of Glamorgan", "Wrexham"].each do |i|
      District.find_by_district(i).update_attributes(sub_country: 'Wales')
    end

    # Northern Ireland
    ["Antrim", "Ards", "Armagh", "Ballymena", "Ballymoney", "Banbridge", "Belfast", "Carrickfergus", "Castlereagh", "Coleraine", "Cookstown", "Craigavon", "Derry", "Down", "Dungannon", "Fermanagh", "Larne", "Limavady", "Lisburn", "Magherafelt", "Moyle", "Newry and Mourne", "Newtownabbey", "North Down", "Omagh", "Strabane"].each do |i|
      District.find_by_district(i).update_attributes(sub_country: 'Northern Ireland')
    end
  end

end
