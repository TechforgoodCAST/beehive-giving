class Funder < ApplicationRecord
  has_many :users, as: :organisation, dependent: :destroy
  has_many :funds

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validates :website, format: {
    with: URI.regexp(%w[http https]),
    message: 'enter a valid website address e.g. http://www.example.com'
  }, if: :website?

  before_validation :set_slug

  def to_param
    slug
  end

  private

    def set_slug
      self.slug = generate_slug(self, name)
    end
end
