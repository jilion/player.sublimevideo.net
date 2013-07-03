FactoryGirl.define do

  factory :package do
    zip { File.new(Rails.root.join('spec/fixtures/packages/sony-player-2.0.0-alpha.zip')) }

    factory :classic_player_controls_1_0_0 do
      zip { File.new(Rails.root.join('spec/fixtures/packages/classic-player-controls-1.0.0.zip')) }
    end

    factory :sony_player_1_0_0 do
      zip { File.new(Rails.root.join('spec/fixtures/packages/sony-player-1.0.0.zip')) }

      factory :sony_player_2_0_0_alpha do
        zip { File.new(Rails.root.join('spec/fixtures/packages/sony-player-2.0.0-alpha.zip')) }
      end
    end
  end

  factory :app do
    sequence(:token) { |n| "#{n}" }
  end

  factory :loader do
    app
    site_token 'abcd1234'
    stage      'stable'
  end

end
