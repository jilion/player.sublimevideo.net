FactoryGirl.define do

  # ===============
  # = User models =
  # ===============
  factory :package do
    sequence(:name) { |n| "package #{n}" }
    version     '1.0.0'
  end

end
