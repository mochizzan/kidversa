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
      response.stream.write ":" + (" " * 2048) + "\n"
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

              # Ekstrak JSON (menangani format 'data: ' atau 'data:')
              clean_json = trimmed_line.sub(/^data:\s?/, "").strip

              begin
                data = JSON.parse(clean_json, symbolize_names: true)
                puts "AI PROCESSING: #{data[:type]}" # Log singkat di terminal
                STDOUT.flush

                # Try to find content in different possible locations
                content_raw = data.dig(:outputs, 0, :content) || data[:content] || data
                content_list = content_raw.is_a?(Array) ? content_raw : [ content_raw ]

                content_list.each do |item|
                  if item.is_a?(Hash)
                    type = item[:type] || item[:object]

                    if type == "thinking"
                      thinking_val = item[:thinking] || item[:content]
                      text = thinking_val.is_a?(Array) ? thinking_val.map { |t| t[:text] }.join : thinking_val
                      sse.write({ type: "thinking", content: text }) if text.present?
                    elsif [ "text", "answer", "message", "message.output.delta" ].include?(type) || item[:content].present?
                      # Check nested content if present
                      nested_content = item[:content]
                      if nested_content.is_a?(Hash) && nested_content[:type] == "thinking"
                        thinking_val = nested_content[:thinking]
                        text = thinking_val.is_a?(Array) ? thinking_val.map { |t| (t.is_a?(Hash) ? t[:text] : t) }.join : thinking_val
                        sse.write({ type: "thinking", content: text }) if text.present?
                      else
                        text = item[:text] || (nested_content.is_a?(String) ? nested_content : nil) || nested_content&.dig(:text)
                        if text.present?
                          full_message += text
                          sse.write({ type: "text", content: text })
                        end
                      end
                    end
                  elsif item.is_a?(String)
                    # Direct string content
                    full_message += item
                    sse.write({ type: "text", content: item })
                  end
                end
              rescue JSON::ParserError => e
                puts "Partial or invalid JSON skipped in chunk: #{e.message}"
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
