class Resource < ApplicationRecord
  # A constant, indicated in Ruby by a name starting with a capital letter
  ONLY_NUMBERS_REGEX = /\A\d+\z/
  validates :uid, presence: true, format: { with: ONLY_NUMBERS_REGEX }, uniqueness: true
  validates :name, presence: true
end
