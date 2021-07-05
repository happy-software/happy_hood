class House < ApplicationRecord
  belongs_to :hood
  has_many :home_owners_associations, through: :hood
  has_one :house_metadatum, dependent: :destroy

  # Helpers to query json columns
  scope :with_street_address, ->(address) { with_address_attr(street_address: address) }
  scope :with_city, ->(city) { with_address_attr(city: city) }
  scope :with_state, ->(state) { with_address_attr(state: state) }
  scope :with_zip_code, ->(zip_code) { with_address_attr(zip_code: zip_code) }

  scope :with_address_attr, ->(**attrs) do
    query_fragments = attrs.map do |attr, val|
      ActiveRecord::Base.sanitize_sql(["address->:attr ? :val", attr: attr, val: val])
    end

    where(query_fragments.join(" AND "))
  end

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
