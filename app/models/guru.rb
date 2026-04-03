class Guru < ApplicationRecord
  self.table_name = "guru" # Assuming heidisql manual table is named 'guru' in singular like 'siswa'
  self.primary_key = "guru_id"
  has_one :user, foreign_key: "guru_id"
  belongs_to :lembaga, foreign_key: "lembaga_id", optional: true

  def nama_sekolah
    lembaga&.nama_lembaga
  end

  def nama_sekolah=(val)
    self.lembaga = Lembaga.find_or_create_by(nama_lembaga: val) if val.present?
  end

  before_create :generate_id

  private

  def generate_id
    self.guru_id = SecureRandom.uuid unless self.guru_id.present?
  end
end
