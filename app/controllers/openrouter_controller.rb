class OpenrouterController
  def self.index(siswa_id)
    apiKey = "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"

    client = Faraday.new(
    url: "https://openrouter.ai/api/v1/chat/completions",
    headers: {
      "Authorization" => "Bearer #{apiKey}",
      "Content-Type" => "application/json",
      "HTTP-Referer" => "app.kidversa.fun"
    }
  )

    data_nilai = NilaiSiswa.where(siswa_id: siswa_id).joins(:pertanyaan).joins(:siswa)
    messages_data = {
      model: "google/gemini-2.5-flash-lite",
         messages: [
          { role: "system", content: "Kamu adalah AI asisten pendidikan anak usia dini yang membantu guru membuat catatan perkembangan siswa berdasarkan hasil penilaian assessment pada sistem raport digital. Tugas utama kamu adalah menghasilkan catatan perkembangan siswa secara deskriptif berdasarkan nilai assessment yang diberikan oleh guru. Gunakan bahasa Indonesia yang baik dan benar sesuai KBBI dengan gaya penulisan catatan raport PAUD yang positif, profesional, dan konstruktif. Catatan harus menggambarkan perkembangan siswa secara umum berdasarkan nilai yang diberikan serta memberikan saran pengembangan jika terdapat aspek yang masih berkembang. Jika terdapat nilai yang masih perlu ditingkatkan, sampaikan secara halus dalam bentuk saran pengembangan tanpa menggunakan kata-kata negatif. Aturan yang wajib diikuti adalah gunakan bahasa Indonesia yang baik dan benar sesuai KBBI, gunakan kalimat yang positif, sopan, dan profesional seperti gaya penulisan raport PAUD, hindari penggunaan kata negatif seperti buruk, gagal, tidak mampu, dan lemah, jika terdapat aspek yang masih berkembang sampaikan dalam bentuk saran pengembangan yang halus, panjang catatan harus 2 sampai 4 kalimat saja, catatan harus fokus pada perkembangan siswa berdasarkan nilai assessment yang diberikan, jangan menambahkan informasi yang tidak ada pada data input, serta variasikan struktur kalimat agar catatan antar siswa tidak terlihat sama walaupun nilai assessment serupa." },
          { role: "user", content: "Buatkan catatan perkembangan siswa berdasarkan data berikut => nama: #{data_nilai.pick(:nama)}, pertanyaan dan nilai assesment: #{data_nilai.pluck(:nama_pertanyaan, :nilai)}. Berikan langsung kalimat catatan, tidak perlu ada intro atau outro" }
        ]
    }

    response = client.post() do |req|
      req.body = messages_data.to_json
    end

    response_parse = JSON.parse(response.body, symbolize_names: true)
    puts "AI JSON PARSE: #{response_parse}"
    puts "AI MESSAGE: #{response_parse[:choices][0][:message][:content]}"
    response_parse[:choices][0][:message][:content]
  end
end
