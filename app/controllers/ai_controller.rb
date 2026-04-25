class AiController
  def self.index(siswa_id, &block)
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
      "stream": true,
      "inputs": [
        { role: "user", content: "Buatkan catatan perkembangan siswa berdasarkan data berikut => nama: #{data_nilai.pick(:nama)}, pertanyaan dan nilai assesment: #{data_nilai.pluck(:nama_pertanyaan, :nilai)}. Berikan langsung kalimat catatan, tidak perlu ada intro atau outro" }
      ]
    }

    if block_given?
      client.post do |req|
        req.body = messages_data.to_json
        req.options.on_data = Proc.new do |chunk, overall_received_bytes|
          block.call(chunk)
        end
      end
      nil
    else
      response = client.post do |req|
        req.body = messages_data.merge(stream: false).to_json
      end
      response_data = JSON.parse(response.body, symbolize_names: true) rescue {}
      content = response_data.dig(:outputs, 0, :content)
      if content.is_a?(Array)
        content.find { |c| c[:type] == "text" }&.dig(:text) || content.to_json
      else
        content.to_s
      end
    end
  end
end
