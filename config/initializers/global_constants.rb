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
