class TahunAjaran < ApplicationRecord
  self.primary_key = "id"
  self.table_name = "tahun_ajaran"
  has_many :nilai_siswas, foreign_key: "tahun_ajaran_id", class_name: "NilaiSiswa"
  has_many :riwayats, foreign_key: "tahun_ajaran_id", class_name: "Riwayat"
  has_many :status_penilaians, foreign_key: "tahun_ajaran_id", class_name: "StatusPenilaian"

  validates :nama, presence: true
end
