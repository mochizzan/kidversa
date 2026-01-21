class Guru < ApplicationRecord
  self.primary_key = "guru_id"
  self.table_name = "guru"
  self.record_timestamps = false

  before_create :generate_id

  has_many :siswas, foreign_key: "guru_id", class_name: "Siswa"
  has_many :nilai_siswas, foreign_key: "guru_id", class_name: "NilaiSiswa"
  has_one :user, foreign_key: "guru_id", class_name: "User"

  private
  def generate_id
    self.guru_id = SecureRandom.uuid
  end
end
