class HomeOwnersAssociation < ApplicationRecord
  has_many :news_posts
  belongs_to :hood
  has_many :houses, through: :hood

end
