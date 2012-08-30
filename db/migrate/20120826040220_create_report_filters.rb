class CreateReportFilters < ActiveRecord::Migration
  def change
    create_table :report_filters do |t|
      t.integer :report_id
      t.integer :report_group
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
