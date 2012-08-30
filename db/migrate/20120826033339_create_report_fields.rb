class CreateReportFields < ActiveRecord::Migration
  def change
    create_table :report_fields do |t|
      t.integer :report_id
      t.string :name
      t.integer :sort_order

      t.timestamps
    end
  end
end
