class House < ApplicationRecord
  belongs_to :hood
  has_many :home_owners_associations, through: :hood
  has_one :house_metadatum, dependent: :destroy

  # Helpers to query json columns
  scope :with_street_address, ->(address) { where("address->'street_address' ? :address", address: address) }
  scope :with_city, ->(city) { where("address->'city' ? :city", city: city) }
  scope :with_state, ->(state) { where("address->'state' ? :state", state: state) }
  scope :with_zip_code, ->(zip_code) { where("address->'zip_code' ? :zip_code", zip_code: zip_code) }

  delegate :zpid, to: :house_metadatum, allow_nil: true

  after_initialize :set_price_history

  PRICE_HISTORY_DATE_FORMAT = "%Y-%m-%d".freeze

  def valuation_on(date)
    normalized_date = date.strftime(PRICE_HISTORY_DATE_FORMAT)
    price_history.dig(normalized_date).to_f
  end

  def add_valuation(date, price)
    normalized_valuation_date = date.strftime(PRICE_HISTORY_DATE_FORMAT)
    price_history[normalized_valuation_date] = price.to_f

    self
  end

  def street_address
    address["street_address"]
  end

  def city
    address["city"]
  end

  def state
    address["state"]
  end

  def zip_code
    address["zip_code"]
  end

  private

  def set_price_history
    self.price_history ||= {}
  end
end
