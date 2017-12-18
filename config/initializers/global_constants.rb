HASHID = Hashids.new(ENV['HASHIDS_SALT'] || 'salt', 8, Hashids::DEFAULT_ALPHABET + '-')
RECOMMENDATION_THRESHOLD = 1
MAX_FREE_LIMIT = 3
RECOMMENDATION_LIMIT = 6

ORG_TYPES = [
  # Name for user, id, plural description
  ['Myself OR another individual', -1, 'individuals'],
  ['An unregistered organisation OR project', 0, 'unregistered organisations'],
  ['A registered charity', 1, 'registered charities'],
  ['A registered company', 2, 'registered companies'],
  ['A registered charity & company', 3, 'charities registered as companies'],
  ['Another type of organisation', 4, 'other types of organisation'],
  ['Community Interest Company', 5, 'Community Interest Companies']
].freeze

FUNDING_TYPES = [
  ["Don't know", 0],
  ['Capital funding - purchase and refurbishment of equipment, and buildings', 1],
  ['Revenue funding - running costs, salaries and activity costs', 2],
  ['Other', 3]
].freeze

OPERATING_FOR = [
  ['Yet to start', 0],
  ['Less than 12 months', 1],
  ['Less than 3 years', 2],
  ['4 years or more', 3]
].freeze

INCOME_BANDS = [
  ['Less than £10k', 0, 0, 10_000],
  ['£10k - £100k', 1, 10_000, 100_000],
  ['£100k - £1m', 2, 100_000, 1_000_000],
  ['£1m - £10m', 3, 1_000_000, 10_000_000],
  ['£10m+', 4, 10_000_000, Float::INFINITY]
].freeze

EMPLOYEES = [
  ['None', 0, 0, 0],
  ['1 - 5', 1, 1, 5],
  ['6 - 25', 2, 6, 25],
  ['26 - 50', 3, 26, 50],
  ['51 - 100', 4, 51, 100],
  ['101 - 250', 5, 101, 250],
  ['251 - 500', 6, 251, 500],
  ['500+', 7, 501, Float::INFINITY]
].freeze