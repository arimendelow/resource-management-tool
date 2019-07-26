class Resource < ApplicationRecord
  ONLY_NUMBERS_REGEX = /\A[0-9]+\z/
  validates :uid, presence: true, format: { with: ONLY_NUMBERS_REGEX }
  validates :name, presence: true
end
