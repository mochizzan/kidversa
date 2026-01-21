class StatusPenilaian < ApplicationRecord
  self.table_name = "status_penilaian"

  before_create :status_genreate

  belongs_to :siswa, foreign_key: "siswa_id", class_name: "Siswa"
  belongs_to :tahun_ajaran, foreign_key: "tahun_ajaran_id", class_name: "TahunAjaran"

  private
  def status_genreate
    self.status = Time.now
  end
end
