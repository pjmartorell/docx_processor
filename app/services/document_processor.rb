require 'zip'
require 'active_model'

class DocumentProcessor
  include ActiveModel::Validations

  attr_accessor :files

  validate :validate_files_presence
  validate :validate_files_type

  def initialize(files)
    @files = files
  end

  def perform
    return false unless valid?

    processed_files = process_docx_files(files)
    create_zip_file(processed_files)
  end

  private

  def validate_files_presence
    errors.add(:base, "No heu seleccionat cap fitxer") if files.blank?
  end

  def validate_files_type
    return if files.blank?

    files.each do |file|
      unless file.content_type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        errors.add(:base, "#{file.original_filename} no és un fitxer docx vàlid")
      end
    end
  end

  private

  def process_docx_files(files)
    processed_files = []
    files.each do |file|
      processed_file = process_docx_file(file)
      processed_files << processed_file if processed_file
    end
    processed_files
  end

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
