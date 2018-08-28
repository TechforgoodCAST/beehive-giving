HASHID = Hashids.new(ENV['HASHIDS_SALT'] || 'salt', 8, Hashids::DEFAULT_ALPHABET + '-')
MAX_FREE_LIMIT = 3 # TODO: refactor
TERMS_VERSION = Date.new(2018, 02, 13)

UNASSESSED = nil
ELIGIBLE   = 1
INCOMPLETE = 0
INELIGIBLE = -1

# TODO: remove
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

# TODO: review/move
FUNDING_TYPES = [
  ["Don't know", 0],
  ['Capital funding - purchase and refurbishment of equipment, and buildings', 1],
  ['Revenue funding - running costs, salaries and activity costs', 2],
  ['Other', 3]
].freeze

# TODO: review/move
OPERATING_FOR = [
  ['Yet to start', 0],
  ['Less than 12 months', 1],
  ['Less than 3 years', 2],
  ['4 years or more', 3]
].freeze

# TODO: review/move
INCOME_BANDS = [
  ['Less than £10k', 0, 0, 9_999],
  ['£10k - £99k', 1, 10_000, 99_999],
  ['£100k - £999k', 2, 100_000, 999_999],
  ['£1m - £10m', 3, 1_000_000, 10_000_000],
  ['More than £10m', 4, 10_000_001, Float::INFINITY]
].freeze

# TODO: remove
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
