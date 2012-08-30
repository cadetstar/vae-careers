class AddValidationTypeToReportFilters < ActiveRecord::Migration
  def change
    add_column :report_filters, :validation_type, :string

  end
end
