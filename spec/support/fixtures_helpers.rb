module Spec
  module Support
    module FixturesHelpers

      def fixture_dir
        Rails.root.join('spec/fixtures')
      end

      def fixture_file(path, mode = 'r')
        File.new(fixture_dir.join(path), mode)
      end

    end
  end
end

RSpec.configure do |config|
  config.include Spec::Support::FixturesHelpers
end
