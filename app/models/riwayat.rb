class Riwayat < ApplicationRecord
  self.table_name = "riwayat"

  belongs_to :siswa, foreign_key: "siswa_id", class_name: "Siswa"
  belongs_to :tahun_ajaran, foreign_key: "tahun_ajaran_id", class_name: "TahunAjaran"
end
