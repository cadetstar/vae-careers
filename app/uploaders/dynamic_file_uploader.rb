# encoding: utf-8

class DynamicFileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "forms/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
     %w(pdf)
  end
end
