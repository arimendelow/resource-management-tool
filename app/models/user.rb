class User < ApplicationRecord
  # 'dependent: :destroy' ensures that if a user is deleted, so are his corresponding microposts
  has_many :microposts, dependent: :destroy
  # For following users - stored in the Relationship table, and the foreign key for a given user is the 'follower_id'
  # Destroying a user should also destroy a user's relationships, hence the 'dependent: :destroy'
  has_many :active_relationships,   class_name: "Relationship",
                                    foreign_key: "follower_id",
                                    dependent: :destroy
  has_many :passive_replationships, class_name: "Relationship",
                                    foreign_key: "followed_id",
                                    dependent: :destroy
  # Leads to a powerful combination of Active Record and array-like behavior.
  # For example, we can check if the followed users collection includes another user with the include? method,
  # or find objects through the association:
  #   user.following.include?(other_user)
  #   user.following.find(other_user)
  # We can also add and delete elements just as with arrays:
  #   user.following << other_user (the shovel operator << appends to the end of an array)
  #   user.following.delete(other_user)
  # Although in many contexts we can effectively treat following as an array, Rails is smart
  # about how it handles things under the hood. For example, code like
  #   following.include?(other_user)
  # looks like it might have to pull all the followed users out of the database to apply the include? method,
  # but in fact for efficiency Rails arranges for the comparison to happen directly in the database.
  # Also, Rails allows us to override the default, in this case using the source parameter,
  # which explicitly tells Rails that the source of the following array is the set of followed ids.
  has_many :following, through: :active_relationships,    source: :followed
  # Here, we don't actually need the 'source' key, because in the case of a :followers attribute, Rails will singularize “followers” and automatically look for the foreign key follower_id in this case
  # I've left it anyway to emphasize the parallel structure with the has_many :following association
  has_many :followers, through: :passive_replationships,  source: :follower
  # Creates getter and setter methods corresponding to a user's 'remember_token' etc
  # This allows us to get and set a @remember_token instance variable
  attr_accessor :remember_token, :activation_token, :reset_token

  # Ensure that all emails are stored in lowercase
  before_save :downcase_email

  # For email activation
  before_create :create_activation_digest

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
  # Check here for regex rules: https://rubular.com

  # This method adds the following functionality:
  # - The ability to saved a hashed password_digest attribute to the database
  # - A pair of virtual attributes (password and password_confirmation), including presnce validations upon object creation and a validation requiring that they match
  # - An 'authenticate' method that returns the user when the password is correct (and 'false' otherwise)
  # The only requirement for this method to work is for the model to have an attribute called 'password_digest'
  has_secure_password
  # 'allow_nil: true' means that the password fields can be empty.
  # This both allows the update page to not require a user to enter their password,
  # and avoids a duplicate error message on the signup page of "password is missing"
  # as 'has_secure_password' already includes a seperate presence validation that specifically catches nil passwords
  validates :password, presence: true, length: { minimum: 8 }, allow_nil: true

  # Returns the hash digest of the given string using the minimum cost parameter in tests and a normal (high) cost parameter in production
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random base64 token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for user in persistent sessions (staying logged in when the window is closed)
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(attribute, token)
    # 'send' lets us call a method with a name of our choice by "sending" a message to a given object
    # It sends whatever we pass in to that object instance and its ancestors in the class
    # hierarchy until some method reacts - 
    # meaning that it 'has the same name'.
    # So this is really just a way of calling 'digest.activate_token' or 'digest.remember_token', etc.
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activate the user
  def activate
    update_columns(
      activated: true,
      activated_at: Time.zone.now,
      activation_digest: nil,
    )
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # For resetting a user's password
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # Send the password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Check if a password reset request has expired - returns a boolean value
  def password_reset_expired?
    # "The password reset was sent earlier than two hours ago."
    reset_sent_at < 2.hours.ago
  end

  # For logging out a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Defines a feed of microposts
  def feed
    # The ? ensures that 'id' is properly escaped before being included in hte underlying SQL query, avoiding a security hole called SQL injection
    # ID here is just an integer, so there's no danger of SQL injection, but it's a good habit to always escape variables injected into SQL statements
    # We want the microposts IF the ID is that of a user that this user is following, or of himself
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # Follows a user
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Determines if the user is following a specific user
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # Converts email to lowercase
    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
