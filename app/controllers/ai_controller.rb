class AiController
  def self.index(siswa_id)
    apiKey = "o489kR8gSqREsZGb4dGQ2iMN6FU85NbD"

    client = Faraday.new(
      url: "https://api.mistral.ai/v1/conversations",
      headers: {
        "Authorization" => "Bearer #{apiKey}",
        "Content-Type" => "application/json",
        "HTTP-Referer" => "app.kidversa.fun"
      }
    )

    data_nilai = NilaiSiswa.where(siswa_id: siswa_id).joins(:pertanyaan).joins(:siswa)

    messages_data = {
      "agent_id": "ag_019dc3f302c376809afb716c0c84ddf8",
      "agent_version": 4,
      "stream": false,
      "inputs": [
        { role: "user", content: "Buatkan catatan perkembangan siswa berdasarkan data berikut => nama: #{data_nilai.pick(:nama)}, pertanyaan dan nilai assesment: #{data_nilai.pluck(:nama_pertanyaan, :nilai)}. Berikan langsung kalimat catatan, tidak perlu ada intro atau outro" }
      ]
    }

    response = client.post do |req|
      req.body = messages_data.to_json
    end
    
    response_data = JSON.parse(response.body, symbolize_names: true) rescue {}
    content = response_data.dig(:outputs, 0, :content) || response_data.dig(:choices, 0, :message, :content)
    
    if content.is_a?(Array)
      # Cari tipe teks secara spesifik
      text_block = content.find { |c| c[:type] == "text" }
      if text_block
        text_block[:text] || text_block[:content] || text_block.to_s
      else
        # Jika Mistral murni hanya menghasilkan thinking secara tersembunyi
        def self.extract_all_strings_ai(obj)
          case obj
          when Hash
            obj.reject { |k, _| k == :type || k == "type" }.values.map { |v| extract_all_strings_ai(v) }.join("")
          when Array
            obj.map { |v| extract_all_strings_ai(v) }.join("")
          when String
            obj
          else
            ""
          end
        end
        extract_all_strings_ai(content)
      end
    else
      content.to_s
    end
  end
end
