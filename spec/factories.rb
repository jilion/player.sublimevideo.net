FactoryGirl.define do

  factory :package do
    sequence(:name) { |n| "package #{n}" }
    version         '2.0.0-alpha'
    zip             { File.new(Rails.root.join('spec/fixtures/packages/sony-player-2.0.0-alpha.zip')) }
  end

  factory :classic_player_controls_1_0_0, class: Package do
    name    { 'classic-player-controls' }
    version '1.0.0'
    zip     { File.new(Rails.root.join('spec/fixtures/packages/classic-player-controls-1.0.0.zip')) }
  end

  factory :sony_player_1_0_0, class: Package do
    name    { 'sony-player' }
    version '1.0.0'
    zip     { File.new(Rails.root.join('spec/fixtures/packages/sony-player-1.0.0.zip')) }
  end

  factory :sony_player_2_0_0_alpha, class: Package do
    name    { 'sony-player' }
    version '2.0.0-alpha'
    zip     { File.new(Rails.root.join('spec/fixtures/packages/sony-player-2.0.0-alpha.zip')) }
  end

  factory :app_bundle do
    token { 'abcd1234' }
  end

  factory :loader do
    site_token { 'abcd1234' }
    app_bundle
  end

end
