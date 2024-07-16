class DocxController < ApplicationController
  def process_docx
    if params[:files].present?
      processed_files = []

      begin
        params[:files].each do |file|
          processed_file = process_docx_file(file)
          processed_files << processed_file if processed_file
        end

        # Create a zip file from processed files
        zip_file_path = create_zip_file(processed_files)

        # Send the zip file for download
        send_file zip_file_path, type: 'application/zip', disposition: 'attachment', filename: 'processed_files.zip'
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

    # Save processed content to an in-memory StringIO object using the stream method
    processed_doc_io = doc.stream

    { original_filename: file.original_filename, doc_io: processed_doc_io }
  end

  def create_zip_file(files)
    zip_file_path = Tempfile.new(%w[processed_files_ .zip]).path
    ::Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip|
      files.each do |entry|
        zip.get_output_stream(entry[:original_filename]) do |stream|
          stream.write(entry[:doc_io].read) # Write the in-memory doc content directly to the zip
        end
      end
    end
    zip_file_path
  end
end
