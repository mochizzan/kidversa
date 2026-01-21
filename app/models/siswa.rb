class Siswa < ApplicationRecord
  self.primary_key = "siswa_id"
  self.table_name = "siswa"

  self.record_timestamps = false

  before_create :generate_id

  belongs_to :guru, foreign_key: "guru_id", class_name: "Guru", optional: true
  belongs_to :orang_tua, foreign_key: "orang_tua_id", class_name: "OrangTua", optional: true
  belongs_to :tahun_ajaran, foreign_key: "tahun_ajaran_id", class_name: "TahunAjaran"

  has_many :nilai_siswas, foreign_key: "siswa_id", class_name: "NilaiSiswa", dependent: :destroy
  has_many :riwayats, foreign_key: "siswa_id", class_name: "Riwayat", dependent: :destroy
  has_many :status_penilaians, foreign_key: "siswa_id", class_name: "StatusPenilaian", dependent: :destroy

  private
  def generate_id
    self.siswa_id = SecureRandom.uuid
  end
end
