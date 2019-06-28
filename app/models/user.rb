class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }

  # A constant, indicated in Ruby by a name starting with a capital letter
  VALID_EMAIL_REGEX = /\A(\w+)([\w+\-.]+)(\w+)(@)([a-z\d]+)([a-z\d\-\.]+)([a-z\d]+)(\.)([a-z]+)\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false } # Rails infirs that uniqueness should be true in addition to case insensitive

  # Explaining that email regex:
  # /             start of regex
  # \A            match start of string
  # \w+           at least one word character
  # [\w+\-.]+     at least one word character, plus a hyphen or dot
  # \w+           at least one word character
  # @             exactly one literal at sign
  # [a-z\d]+      at least one letter or digit
  # [a-z\d\-.]+   at least one letter, digit, hyphen, or dot
  # [a-z\d]+      at least one letter or digit
  # \.            exactly one literal dot
  # [a-z]+        at least one letter
  # \z            match end of string
  # /             end of regex
  # i             case insensitive
  #
  # Check here for regex rules: https://rubular.comokayokaodkfsokafdsofd

end
