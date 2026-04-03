class Lembaga < ApplicationRecord
  self.table_name = "lembaga"
  self.primary_key = "lembaga_id"
  self.record_timestamps = false

  has_many :guru, foreign_key: "lembaga_id"
  has_many :siswa, foreign_key: "lembaga_id"

  before_create :generate_id

  private

  def generate_id
    self.lembaga_id = SecureRandom.uuid unless self.lembaga_id.present?
  end
end
