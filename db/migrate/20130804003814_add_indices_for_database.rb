class AddIndicesForDatabase < ActiveRecord::Migration
  def change
    add_index 'tags', ['tag_type_id']
    add_index 'tags', ['creator_id', 'creator_type']
    add_index 'tags', ['owner_id', 'owner_type']

    add_index 'submission_users', ['submission_id']
    add_index 'submission_users', ['remote_user_id']

    add_index 'submission_answers', ['submission_id']
    add_index 'submission_answers', ['question_id']

    add_index 'submissions', ['opening_id']
    add_index 'submissions', ['applicant_id']

    add_index 'static_texts', ['name']

    add_index 'report_filters', ['report_id']

    add_index 'report_fields', ['report_id']

    add_index 'reports', ['creator_id']

    add_index 'remote_user_departments', ['remote_user_id'], :name => 'index_ruds_on_rui'
    add_index 'remote_user_departments', ['department_id'], :name => 'index_ruds_on_di'

    add_index 'question_group_connections', ['question_id'], :name => 'index_qgcs_on_qi'
    add_index 'question_group_connections', ['question_group_id'], :name => 'index_qgcs_on_qgi'

    add_index 'positions', ['position_type_id']

    add_index 'phones', ['applicant_id']

    add_index 'opening_group_connections', ['opening_id']
    add_index 'opening_group_connections', ['question_group_id']

    add_index 'openings', ['position_id']
    add_index 'openings', ['department_id']

    add_index 'new_hire_request_skills', ['new_hire_request_id'], :name => 'index_nhrs_on_nhri'
    add_index 'new_hire_request_skills', ['new_hire_skill_id'], :name => 'index_nhrs_on_nhsi'

    add_index 'new_hire_requests', ['position_id']
    add_index 'new_hire_requests', ['department_id']
    add_index 'new_hire_requests', ['creator_id']
    add_index 'new_hire_requests', ['opening_id']
    add_index 'new_hire_requests', ['rejected_by']

    add_index 'new_hire_approvals', ['remote_user_id']
    add_index 'new_hire_approvals', ['new_hire_request_id']

    add_index 'job_agents', ['applicant_id']

    add_index 'file_fields', ['dynamic_file_revision_id'], :name => 'index_ff_on_dfri'

    add_index 'dynamic_form_opening_links', ['file_id', 'file_type'], :name => 'index_dfol_fi_ft'
    add_index 'dynamic_form_opening_links', ['opening_id'], :name => 'index_dfol_on_oi'
    add_index 'dynamic_form_opening_links', ['file_type', 'form_type'], :name => 'index_dfol_on_ft_form_type'

    add_index 'dynamic_file_revisions', ['dynamic_file_id'], :name => 'index_dfr_on_dfi'

    add_index 'dynamic_files', ['current_version_id']

    add_index 'dynamic_file_group_links', ['dynamic_file_id'], :name => 'index_dfgl_on_dfi'
    add_index 'dynamic_file_group_links', ['dynamic_form_group_id'], :name => 'index_dfgl_on_dfgi'

    add_index 'departments', ['supervising_department_id']

    add_index 'demographics', ['submission_id']
    add_index 'demographics', ['opening_id']

    add_index 'comments', ['owner_id', 'owner_type']
    add_index 'comments', ['creator_type', 'creator_id']

    add_index 'applicant_files', ['applicant_id']
    add_index 'applicant_files', ['submission_id']
  end
end
