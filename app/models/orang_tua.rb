class OrangTua < ApplicationRecord
  self.primary_key = "orang_tua_id"
  self.table_name = "orang_tua"
  self.record_timestamps = false

  has_many :siswas, foreign_key: "orang_tua_id", class_name: "Siswa"
end
