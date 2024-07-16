class DocxController < ApplicationController
  def process_docx
    processor = DocumentProcessor.new(params[:files])

    if zip = processor.perform
      send_file zip, type: 'application/zip', disposition: 'attachment', filename: 'processed_files.zip'
    else
      flash[:error] = processor.errors.full_messages.join('. ')
      redirect_to root_path
    end
  end
end
