# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120408143855) do

  create_table "applicants", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "preferred_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
  end

  add_index "applicants", ["email"], :name => "index_applicants_on_email", :unique => true
  add_index "applicants", ["reset_password_token"], :name => "index_applicants_on_reset_password_token", :unique => true

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.string   "state"
    t.string   "code"
    t.integer  "supervising_department_id"
    t.integer  "manager_id"
    t.integer  "supervisor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
  end

  create_table "opening_group_connections", :force => true do |t|
    t.integer  "opening_id"
    t.integer  "question_group_id"
    t.integer  "group_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "openings", :force => true do |t|
    t.integer  "position_id"
    t.integer  "department_id"
    t.text     "description"
    t.text     "high_priority_description"
    t.boolean  "active"
    t.boolean  "show_on_opp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "position_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "positions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "position_type_id"
    t.string   "time_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_group_connections", :force => true do |t|
    t.integer "question_id"
    t.integer "question_group_id"
    t.integer "question_order"
  end

  create_table "question_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.string   "name"
    t.text     "prompt"
    t.string   "question_type"
    t.text     "choices"
    t.boolean  "required"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remote_users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "roles_mask"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submission_answers", :force => true do |t|
    t.text     "question_text"
    t.string   "question_type"
    t.integer  "question_id"
    t.text     "answer"
    t.integer  "submission_id"
    t.integer  "group_order"
    t.integer  "question_order"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "submissions", :force => true do |t|
    t.text     "where_sourced"
    t.integer  "opening_id"
    t.integer  "applicant_id"
    t.boolean  "affidavit"
    t.boolean  "privacy_notice"
    t.string   "recruiter_recommendation"
    t.boolean  "hired"
    t.boolean  "began_hiring"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.boolean  "completed"
  end

end
