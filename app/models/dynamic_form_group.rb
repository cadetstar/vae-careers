class DynamicFormGroup < ActiveRecord::Base
  has_many :dynamic_file_group_links, :order => :group_order
  has_many :dynamic_files, :through => :dynamic_file_group_links, :order => "dynamic_file_group_links.group_order"

  has_many :dynamic_form_opening_links, :as => :owner

  def included_files
    dynamic_files.collect{|df| df.to_s}.join('<br />')
  end

  def tooltip
    name
  end

  def to_s
    name
  end

  def self.indexed_attributes
    %w(name included_files)
  end
end
