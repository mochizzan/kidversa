# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 0) do
  create_table "nilai_siswa", primary_key: "nilai_id", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.timestamp "created_at", default: -> { "(now())" }, null: false
    t.integer "nilai", default: 0, null: false
    t.integer "pertanyaan_id", default: -> { "(uuid_short())" }, null: false
    t.integer "siswa_id", default: -> { "(uuid())" }, null: false
    t.timestamp "updated_at", default: -> { "(now())" }, null: false
  end

  create_table "pertanyaan", primary_key: "pertanyaan_id", id: :integer, default: -> { "(uuid_short())" }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.timestamp "created_at", default: -> { "(now())" }, null: false
    t.string "nama_pertanyaan", limit: 50, default: "", null: false
    t.timestamp "updated_at", default: -> { "(now())" }, null: false
  end

  create_table "siswa", primary_key: "siswa_id", id: :integer, default: -> { "(uuid())" }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.timestamp "created_at", default: -> { "(now())" }, null: false
    t.string "ibu_kandung", default: "", null: false
    t.string "nama", default: "", null: false
    t.integer "nisn"
    t.string "tingkat", limit: 25
    t.timestamp "update_at", default: -> { "(now())" }, null: false
    t.index ["nisn"], name: "nisn", unique: true
  end

  create_table "users", primary_key: "user_id", id: :integer, default: -> { "(uuid_short())" }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.timestamp "created_at", default: -> { "(now())" }, null: false
    t.string "password", default: "", null: false, collation: "utf8mb4_bin"
    t.integer "role", limit: 1, default: -> { "(0)" }, null: false
    t.timestamp "updated_at", default: -> { "(now())" }, null: false
    t.string "username", limit: 50, default: "", null: false
    t.index ["username"], name: "username", unique: true
  end
end
