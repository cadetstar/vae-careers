module Mapping
  TABLEMAPPER = {
      'posjobtypes' => {
          :model => PositionType,
          :fields => {
              "name" => "typename"
          }
      },
      'positions' => {
          :model => Position,
          :fields => {
              "name" => "posname",
              "description" => "posdescription",
              "position_type_id" => "posjobtype_id",
              "time_type" => "postimetype"
          }
      },
      'appquestions' => {
          :model => Question,
          :fields => {
              'name' => 'ident',
              'prompt' => 'qtext',
              'required' => 'isrequired'
          }
      },
      'appqgroups' => {
          :model => QuestionGroup,
          :fields => {
              'name' => 'grpident'
          }
      },
      'grpquestions' => {
          :model => QuestionGroupConnection,
          :fields => {
              'question_id' => 'appquestion_id',
              'question_group_id' => 'appqgroup_id'
          }
      },
      'openinggroups' => {
          :model => OpeningGroupConnection,
          :fields => {
              'question_group_id' => 'appqgroup_id'
          }
      },
      'openings' => {
          :model => Opening,
          :fields => {
              'high_priority_description' => 'highpriority',
              'show_on_opp' => 'showopp'
          }
      },
      'demodatas' => {
          :model => Demographic,
          :fields => {}
      },
      'applicants' => {
          :model => Submission
      },
      'nhskills' => {
          :model =>  NewHireSkill,
          :fields => {}
      },
      'newhirerequests' => {
          :model => NewHireRequest,
          :fields => {}
      },
      'skillrequests' => {
          :model => NewHireRequestSkill,
          :fields => {
              'new_hire_request_id' => 'newhirerequest_id',
              'new_hire_skill_id' => 'nhskill_id'
          }
      },
      'approvals' => {
          :model => NewHireApproval,
          :fields => {
              'remote_user_id' => 'user_id',
              'new_hire_request_id' => 'newhirerequest_id'
          }
      }
  }
end