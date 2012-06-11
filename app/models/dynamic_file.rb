class DynamicFile < ActiveRecord::Base
  has_many :dynamic_file_revisions
  has_many :file_fields, :through => :dynamic_file_revisions
  belongs_to :current_version, :class_name => "DynamicFileRevision"

  has_many :dynamic_file_group_links
  has_many :dynamic_form_groups, :through => :dynamic_file_group_links

  has_many :dynamic_form_opening_links, :as => :owner

  accepts_nested_attributes_for :file_fields
  accepts_nested_attributes_for :dynamic_file_revisions

  after_save :check_for_default

  def self.indexed_attributes
    %w(name confirmation_notice)
  end

  def check_for_default
    if self.current_version.nil? and (k = self.dynamic_file_revisions.first)
      self.current_version = k
      self.save
    end
  end
end
