class House < ApplicationRecord
  belongs_to :hood
  has_many :home_owners_associations, through: :hood
  has_one :house_metadatum, dependent: :destroy

  PRICE_HISTORY_DATE_FORMAT = "%Y-%m-%d".freeze

  after_initialize :set_price_history

  def valuation_on(date)
    normalized_date = date.strftime(PRICE_HISTORY_DATE_FORMAT)
    price_history.dig(normalized_date).to_f
  end

  def add_valuation(date, price)
    normalized_valuation_date = date.strftime(PRICE_HISTORY_DATE_FORMAT)
    price_history[normalized_valuation_date] = price.to_f

    self
  end

  private

  def set_price_history
    self.price_history ||= {}
  end
end
