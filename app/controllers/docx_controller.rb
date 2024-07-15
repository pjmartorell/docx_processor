class DocxController < ApplicationController
  def process_docx
    if params[:files].present?
      processed_files = []

      begin
        params[:files].each do |file|
          processed_file = process_docx_file(file) # Add your processing logic here
          processed_files << processed_file if processed_file
        end

        # Create a zip file from processed files
        zip_file_path = create_zip_file(processed_files)

        # Send the zip file for download
        send_file zip_file_path, type: 'application/zip', disposition: 'attachment', filename: 'processed_files.zip'
      ensure
        # Cleanup temporary files
        processed_files.each { |entry| entry[:temp_file].close! }
      end
    else
      flash[:error] = 'No heu seleccionat cap fitxer 🙃'
      redirect_to root_path
    end
  end

  private

  def process_docx_file(file)
    # Process the DocX file
    doc = Docx::Document.open(file.tempfile)

    # Example processing: Remove the second paragraph if it exists
    doc.paragraphs.at(2).remove! if doc.paragraphs.size > 2

    # Save processed content to a temporary file
    temp_file = Tempfile.new(%w[processed_ .docx])
    doc.save(temp_file.path)

    { original_filename: file.original_filename, temp_file: temp_file }
  end

  def create_zip_file(files)
    zip_file_path = Tempfile.new(%w[processed_files_ .zip]).path
    ::Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip|
      files.each do |entry|
        zip.add(entry[:original_filename], entry[:temp_file].path)
      end
    end
    zip_file_path
  end
end
