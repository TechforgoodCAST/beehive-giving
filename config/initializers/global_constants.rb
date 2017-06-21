RECOMMENDATION_THRESHOLD = 1
MAX_FREE_LIMIT = 3
RECOMMENDATION_LIMIT = 6

ORG_TYPES = [
  ['Myself OR another individual', -1],
  ['An unregistered organisation OR project', 0],
  ['A registered charity', 1],
  ['A registered company', 2],
  ['A registered charity & company', 3],
  ['Another type of organisation', 4],
  ['Community Interest Company', 5]
].freeze

FUNDING_TYPES = [
  ["Don't know", 0],
  ['Capital funding - purchase and refurbishment of equipment, and buildings', 1],
  ['Revenue funding - running costs, salaries and activity costs', 2],
  ['Other', 3]
].freeze
