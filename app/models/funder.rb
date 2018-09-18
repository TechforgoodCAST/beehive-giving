class Funder < ApplicationRecord
  has_many :attempts
  has_many :funds
  has_many :proposals, as: :collection # TODO: test

  # TODO: test
  has_many :criteria, -> { distinct }, through: :funds
  has_many :priorities, -> { distinct }, through: :funds
  has_many :restrictions, -> { distinct }, through: :funds

  has_many :users, as: :organisation, dependent: :destroy

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validates :website, format: {
    with: URI.regexp(%w[http https]),
    message: 'enter a valid website address e.g. http://www.example.com'
  }, if: :website?

  before_validation :set_slug, unless: :slug

  def to_param
    slug
  end

  private

    def set_slug
      self.slug = generate_slug(self, name)
    end
end
