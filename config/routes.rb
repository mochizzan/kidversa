Rails.application.routes.draw do
  scope "/admin" do
    get "index" => "admin#index", as: :admin
    get "data_nilai" => "admin#data_nilai", as: :data_nilai
    post "data_nilai/simpan_catatan" => "admin#simpan_catatan", as: :simpan_catatan

    post "tambah_tahun_ajaran" => "admin#tambah_tahun_ajaran", as: :tambah_tahun_ajaran
    post "ganti_tahun_ajaran_aktif" => "admin#ganti_tahun_ajaran_aktif", as: :ganti_tahun_ajaran_aktif

    get "penilaian/index" => "penilaian#index", as: :penilaian
    post "penilaian/simpan" => "penilaian#simpan_penilaian", as: :simpan_penilaian
    post "penilaian/reset" => "penilaian#reset_penilaian", as: :reset_penilaian

    get "data_siswa" => "admin#data_siswa", as: :data_siswa
    post "data_siswa/tambah_data_siswa" => "admin#tambah_data_siswa", as: :tambah_data_siswa
    post "data_siswa/edit_data_siswa" => "admin#edit_data_siswa", as: :edit_data_siswa
    post "data_siswa/hapus_data_siswa/:siswa_id" => "admin#hapus_data_siswa", as: :hapus_data_siswa
    post "migrasi_data_siswa" => "admin#migrasi_data_siswa", as: :migrasi_data_siswa

    get "data_pertanyaan" => "admin#data_pertanyaan", as: :data_pertanyaan
    post "data_pertanyaan/tambah_data_pertanyaan" => "admin#tambah_data_pertanyaan", as: :tambah_data_pertanyaan
    post "data_pertanyaan/edit_data_pertanyaan" => "admin#edit_data_pertanyaan", as: :edit_data_pertanyaan
    post "data_pertanyaan/delete_data_pertanyaan" => "admin#delete_data_pertanyaan", as: :delete_data_pertanyaan
  end

  get "login/index" => "login#index", as: :login
  get "login/logout" => "login#destroy", as: :logout

  get "home/index" => "home#index", as: :home
  get "home/cek_assesment" => "home#cek_assesment", as: :cek_assesment

  get "siswa/index", as: :siswa
  post "siswa/simpan_assesment" => "siswa#simpan_assesment", as: :simpan_assesment

  post "login/index" => "login#create"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
