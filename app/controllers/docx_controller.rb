class DocxController < ApplicationController
  def process_docx
    if params[:files].present?
      processed_files = []

      Async do
        begin
          tasks = params[:files].map do |file|
            Async do
              processed_files << process_docx_file(file)
            end
          end

          tasks.each(&:wait) # Wait for all tasks to complete

          # Create a zip file from processed files
          zip_file_path = create_zip_file(processed_files)

          # Send the zip file for download
          send_file zip_file_path, type: 'application/zip', disposition: 'attachment', filename: 'processed_files.zip'
        rescue => e
          flash[:error] = "Error processing files: #{e.message}"
          redirect_to root_path
        ensure
          processed_files.each { |entry| entry[:temp_file].close! if entry[:temp_file] }
        end
      end
    else
      flash[:error] = 'No heu seleccionat cap fitxer 🙃'
      redirect_to root_path
    end
  end

  private

  def process_docx_file(file)
    doc = Docx::Document.open(file.tempfile)

    # Example processing: Remove the second paragraph if it exists
    doc.paragraphs.at(2).remove! if doc.paragraphs.size > 2

    # Output the processed document as a stream
    processed_doc_io = doc.stream

    { original_filename: file.original_filename, doc_io: processed_doc_io }
  rescue => e
    raise "Failed to process #{file.original_filename}: #{e.message}"
  end

  def create_zip_file(files)
    zip_file_path = Tempfile.new(%w[processed_files_ .zip]).path
    ::Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip|
      files.each do |entry|
        zip.get_output_stream(entry[:original_filename]) do |zip_stream|
          zip_stream.write(entry[:doc_io].read)
        end
      end
    end
    zip_file_path
  end
end
