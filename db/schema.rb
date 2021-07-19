# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_08_162309) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "lead_id"
    t.integer "assigned_to_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "progress"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "availabilities", force: :cascade do |t|
    t.string "day_of_week"
    t.time "start_time"
    t.time "end_time"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_availabilities_on_user_id"
  end

  create_table "demos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lead_id", null: false
    t.datetime "start_datetime"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lead_id"], name: "index_demos_on_lead_id"
    t.index ["user_id"], name: "index_demos_on_user_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "first_name"
    t.string "phone_number"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "heat"
    t.integer "stage"
    t.string "last_name"
    t.string "facebook"
    t.string "instagram"
    t.string "linkedin"
    t.datetime "prospecting_message_send_at"
    t.datetime "contacted_message_send_at"
    t.datetime "demo_message_send_at"
    t.datetime "followup_message_send_at"
    t.datetime "closing_message_send_at"
    t.boolean "is_purchase_subscription", default: false
    t.string "added_from", default: "lead_form"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price"
    t.string "detail", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "second_price"
  end

  create_table "user_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_id", null: false
    t.boolean "status"
    t.string "stripe_subscription"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subscription_id"], name: "index_user_subscriptions_on_subscription_id"
    t.index ["user_id"], name: "index_user_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "domain"
    t.string "zoom_link"
    t.string "full_name"
    t.string "phone_number"
    t.integer "status", default: 0
    t.string "invited_by"
    t.string "twilio_number"
    t.string "affiliate_token"
    t.integer "referred_by_id"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "availabilities", "users"
  add_foreign_key "demos", "leads"
  add_foreign_key "demos", "users"
  add_foreign_key "leads", "users"
  add_foreign_key "user_subscriptions", "subscriptions"
  add_foreign_key "user_subscriptions", "users"
end
