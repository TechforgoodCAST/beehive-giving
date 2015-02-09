class Recipient < Organisation
  has_many :grants
  has_many :features, dependent: :destroy

  def can_request_funder?(funder)
    features.build(data_requested: true, funder: funder).valid?
  end
end
