class House < ApplicationRecord
  belongs_to :hood
  has_many :home_owners_associations, through: :hood
  has_one :house_metadatum, dependent: :destroy

  PRICE_HISTORY_DATE_FORMAT = "%Y-%m-%d".freeze

  def valuation_on(date)
    normalized_date = date.strftime(PRICE_HISTORY_DATE_FORMAT)
    price_history.dig(normalized_date).to_f
  end
end
