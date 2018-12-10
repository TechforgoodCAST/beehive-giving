FactoryBot.define do
  factory :admin_user do
    email { 'admin@admin.com' }
    password { 'password' }
  end
end
