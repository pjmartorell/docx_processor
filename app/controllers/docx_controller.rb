class DocxController < ApplicationController
  def process_docx
    processor = DocumentProcessor.new(params[:files])

    if zip = processor.perform
      send_file zip, type: 'application/zip', disposition: 'attachment', filename: 'processed_files.zip'
    else
      render json: { errors: processor.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
