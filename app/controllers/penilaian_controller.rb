class PenilaianController < AdminController
  include ActionController::Live
  def index
    user_id = session[:user_id]
    siswa_id = params[:siswa_id]
    @data_akun = User.find_by(user_id: user_id)

    @data_siswa = Siswa.find_by(siswa_id: siswa_id)
    @data_pertanyaan = Pertanyaan.all
    @data_guru = Guru.all
    @data_nilai = NilaiSiswa.joins(:guru).joins(:pertanyaan).where(siswa_id: siswa_id)

    @current_catatan = Siswa.where(siswa_id: siswa_id).pick(:catatan)
  end

  def simpan_penilaian
    guru_id = params[:guru_id]
    pertanyaan_id = params[:pertanyaan_id]
    siswa_id = params[:siswa_id]

    ta_aktif = TahunAjaran.find_by(is_active: 1)

    nilai = nil
    bb = params[:nilai_0]
    mb = params[:nilai_1]
    bsh = params[:nilai_2]
    bsb = params[:nilai_3]

    if bb.present?
      nilai = bb
    elsif mb.present?
      nilai = mb
    elsif bsh.present?
      nilai = bsh
    elsif bsb.present?
      nilai = bsb
    end

    current_nilai = NilaiSiswa.find_by(pertanyaan_id: pertanyaan_id, siswa_id: siswa_id)
    if current_nilai
      current_nilai.update(nilai: nilai, guru_id: guru_id)
      flash[:notice] = "Penilaian berhasil diperbarui."
    else
      nilai_siswa = NilaiSiswa.new(
      siswa_id: siswa_id,
      guru_id: guru_id,
      nilai: nilai,
      pertanyaan_id: pertanyaan_id,
      tahun_ajaran_id: ta_aktif.id
    )
      if nilai_siswa.save
        flash[:notice] = "Penilaian berhasil disimpan."
      else
        flash[:alert] = "Penilaian gagal disimpan."
      end
    end

    total_pertanyaan = Pertanyaan.count
    total_nilai_siswa = NilaiSiswa.where(siswa_id: siswa_id).count

    current_status_nilai = StatusPenilaian.find_by(siswa_id: siswa_id, tahun_ajaran_id: ta_aktif.id)

    if total_nilai_siswa >= total_pertanyaan
      if current_status_nilai
        StatusPenilaian.find_by(siswa_id: siswa_id, tahun_ajaran_id: ta_aktif.id).update(status: Time.now)
      else
        StatusPenilaian.create(
        siswa_id: siswa_id,
        tahun_ajaran_id: ta_aktif.id
      )
      is_complete = true
      end
    else
      is_complete = false
    end

    redirect_to penilaian_path(siswa_id: siswa_id, is_complete: is_complete)
  end

  def reset_penilaian
    siswa_id = params[:siswa_id]
    pertanyaan_id = params[:pertanyaan_id]

    current_nilai = NilaiSiswa.find_by(pertanyaan_id: pertanyaan_id, siswa_id: siswa_id)

    if current_nilai
      current_nilai.delete
    end

    redirect_to penilaian_path(siswa_id: siswa_id)
    flash[:notice] = "Penilaian berhasil direset."
  end

  def generate_catatan
    siswa_id = params[:siswa_id]
    current_catatan = Siswa.where(siswa_id: siswa_id).pick(:catatan)

    if params[:stream] == "true" && current_catatan.blank?
      response.headers["Content-Type"] = "text/event-stream"
      response.headers["Last-Modified"] = Time.now.httpdate
      response.headers["X-Accel-Buffering"] = "no"
      response.headers["Cache-Control"] = "no-cache"
      response.headers["Content-Encoding"] = "identity"
      
      sse = SSE.new(response.stream, event: "message")

      full_message = ""
      buffer = ""
      begin
        AiController.index(siswa_id) do |chunk|
          buffer += chunk
          while (newline_index = buffer.index("\n"))
            line = buffer.slice!(0..newline_index)
            trimmed_line = line.strip

            next if trimmed_line.blank?

            if trimmed_line.start_with?("data:")
              next if trimmed_line.include?("[DONE]")

              clean_json = trimmed_line.sub(/^data:\s?/, "").strip

              begin
                data = JSON.parse(clean_json, symbolize_names: true)

                is_thinking_chunk = false
                text_to_send = ""

                # Identifikasi otomatis logika thinking
                raw_str = data.to_s
                if raw_str.include?(":thinking") && !raw_str.include?(":thinking=>[]") && !raw_str.include?(":thinking=>\"\"")
                  is_thinking_chunk = true
                end

                # Ambil Teks output
                payload = data[:choices]&.first&.dig(:delta) || data[:delta] || data[:message] || data[:content] || data

                if payload.is_a?(Hash)
                  if is_thinking_chunk && payload[:thinking].present?
                    val = payload[:thinking]
                    text_to_send = val.is_a?(Array) ? val.map { |v| v.is_a?(Hash) ? v[:text] : v.to_s }.join : val.to_s
                  elsif payload[:text].present?
                    text_to_send = payload[:text]
                  elsif payload[:content].present?
                    val = payload[:content]
                    text_to_send = val.is_a?(Array) ? val.map { |v| v.is_a?(Hash) ? (v[:text]||v[:content]) : v.to_s }.join : val.to_s
                  elsif data[:outputs].is_a?(Array)
                    text_to_send = data[:outputs].map { |o| o[:text] || o[:content] }.compact.join
                  end
                elsif payload.is_a?(String)
                  text_to_send = payload
                elsif payload.is_a?(Array)
                  text_to_send = payload.map { |v| v.is_a?(Hash) ? (v[:text]||v[:content]) : v.to_s }.join
                end

                puts "[RUBY CHUNK] Thinking: #{is_thinking_chunk ? 'YES' : 'NO'} | Txt: #{text_to_send.inspect}"
                STDOUT.flush

                if text_to_send.present?
                  if is_thinking_chunk
                     # Tambahkan byte acak yang tak bisa dikompres GZIP agar buffer Cloudflare/Nginx jebol
                     sse.write({ type: "thinking", content: text_to_send })
                     response.stream.write(":#{SecureRandom.hex(2048)}\n\n")
                  else
                     full_message += text_to_send
                     sse.write({ type: "text", content: text_to_send })
                     response.stream.write(":#{SecureRandom.hex(2048)}\n\n")
                  end
                end
              rescue StandardError => e
                puts "[RUBY PARSE ERR] #{e.message} on #{clean_json[0..100]}..."
              end
            end # end if data:
          end # end while
        end # end AiController.index
        # Save the final result
        Siswa.find_by(siswa_id: siswa_id).update(catatan: full_message) if full_message.present?
      ensure
        sse.close
      end
    else
      if current_catatan.blank?
        @ai_message = AiController.index(siswa_id)
        Siswa.find_by(siswa_id: siswa_id).update(catatan: @ai_message)
      else
        @ai_message = current_catatan
      end

      render turbo_stream: turbo_stream.update("modal-body-ai", @ai_message)
    end
  end
end
