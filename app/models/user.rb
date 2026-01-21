class User < ApplicationRecord
  self.table_name =  "users"
  self.primary_key = "user_id"
  self.record_timestamps = false

  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  belongs_to :guru, foreign_key: "guru_id", optional: true

  before_create :generate_id

  validate :username_different_from_password

  private
  def generate_id
    self.user_id = SecureRandom.uuid
  end

  def username_different_from_password
    if username == password
      errors.add(:password, "password tidak boleh sama dengan username")
    end
  end
end
