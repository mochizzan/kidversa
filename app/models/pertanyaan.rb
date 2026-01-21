class Pertanyaan < ApplicationRecord
  before_create :generate_id
  self.primary_key = "pertanyaan_id"
  self.table_name = "pertanyaan"
  self.record_timestamps = false

  has_many :nilai_siswas, foreign_key: "pertanyaan_id", class_name: "NilaiSiswa"

  private
  def generate_id
    self.pertanyaan_id = SecureRandom.random_number(99_999_999)
  end
end
