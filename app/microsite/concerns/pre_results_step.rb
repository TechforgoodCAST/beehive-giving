class PreResultsStep
  include ActiveModel::Model

  attr_accessor :attempt, :email, :agree_to_terms

  validates :agree_to_terms, presence: true
  validates :email, presence: true, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  }

  def save
    if valid?
      save_attempt! if save_user!
    else
      false
    end
  end

  private

    def save_user!
      user = User.where(email: email).first_or_initialize
      user.assign_attributes(
        agree_to_terms: agree_to_terms,
        organisation: attempt&.recipient
      )
      user.save(validate: false)
    end

    def save_attempt!
      return false unless attempt
      attempt.update(
        state: 'results',
        access_token: SecureRandom.urlsafe_base64
      )
    end
end
