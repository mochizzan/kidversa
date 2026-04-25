require 'mistral'

class AiController
  def self.index(siswa_id, &block)
    api_key = "o489kR8gSqREsZGb4dGQ2iMN6FU85NbD"
    client = Mistral::Client.new(api_key: api_key)

    data_nilai = NilaiSiswa.where(siswa_id: siswa_id).joins(:pertanyaan).joins(:siswa)
    prompt = "Buatkan catatan perkembangan siswa berdasarkan data berikut => nama: #{data_nilai.pick(:nama)}, pertanyaan dan nilai assesment: #{data_nilai.pluck(:nama_pertanyaan, :nilai)}. Berikan langsung kalimat catatan, tidak perlu ada intro atau outro"

    if block_given?
      client.chat_stream(
        model: 'magistral-small-latest',
        messages: [Mistral::ChatMessage.new(role: 'user', content: prompt)]
      ).each do |chunk|
        delta = chunk.choices[0]&.delta
        next unless delta && delta.content

        if delta.content.is_a?(String)
          # Mode teks reguler
          block.call({ type: "text", content: delta.content })
        elsif delta.content.is_a?(Array)
          # Mode array campuran (thinking / text)
          delta.content.each do |item|
            case item['type']
            when 'thinking'
              # Ambil teks dari dalam object 'thinking' pertama, atau jadikan string jika berbeda wujud
              thinking_arr = item['thinking']
              if thinking_arr.is_a?(Array)
                thinking_text = thinking_arr.map { |t| t['text'] || t['content'] }.join
                block.call({ type: "thinking", content: thinking_text }) if thinking_text.present?
              elsif thinking_arr.is_a?(String)
                block.call({ type: "thinking", content: thinking_arr })
              end
            when 'text'
              text_val = item['text'] || item['content']
              block.call({ type: "text", content: text_val }) if text_val.present?
            end
          end
        end
      end
      nil
    else
      # Jika dipanggil tanpa block, kembalikan response statis (walau tidak dimintai untuk kasus ini)
      response = client.chat(
        model: 'magistral-small-latest',
        messages: [Mistral::ChatMessage.new(role: 'user', content: prompt)]
      )
      return response.choices[0]&.message&.content || ""
    end
  end
end
