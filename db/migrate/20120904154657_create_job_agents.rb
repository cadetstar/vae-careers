class CreateJobAgents < ActiveRecord::Migration
  def change
    create_table :job_agents do |t|
      t.integer :applicant_id
      t.text :keywords

      t.timestamps
    end
  end
end
