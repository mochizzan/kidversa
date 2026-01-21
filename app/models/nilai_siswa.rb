class NilaiSiswa < ApplicationRecord
  before_create :generate_id

  self.primary_key = "nilai_id"
  self.table_name = "nilai_siswa"
  self.record_timestamps = false

  belongs_to :siswa, foreign_key: "siswa_id", class_name: "Siswa", optional: true
  belongs_to :guru, foreign_key: "guru_id", class_name: "Guru", optional: true
  belongs_to :pertanyaan, foreign_key: "pertanyaan_id", class_name: "Pertanyaan", optional: true

  belongs_to :tahun_ajaran, foreign_key: "tahun_ajaran_id", class_name: "TahunAjaran"

  private
  def generate_id
    self.nilai_id = SecureRandom.uuid
  end
end
