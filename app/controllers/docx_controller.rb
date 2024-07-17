class DocxController < ApplicationController
  def process_docx
    processor = DocumentProcessor.new(params[:files])

    if zip = processor.perform
      send_file zip, type: 'application/zip', disposition: 'attachment', filename: 'processed_files.zip'
    else
      flash.now[:error] = processor.errors.full_messages.join('. ')
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "layouts/flash") }
      end
    end
  end
end
