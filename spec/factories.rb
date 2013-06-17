FactoryGirl.define do

  factory :package do
    sequence(:name) { |n| "package #{n}" }
    version     '1.0.0'
  end

  factory :app_md5 do
    md5 { 'abcd1234' }
  end

end
