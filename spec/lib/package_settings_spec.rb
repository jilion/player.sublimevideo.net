require 'fast_spec_helper'

require 'package_settings'

describe PackageSettings do
  let(:package_settings) { described_class.new }

  describe '#level' do
    it 'allows to specify a whole level settings with a block' do
      package_settings.level(0) do |level|
        level[:name] = 'sublime'
        level[:template] = {
          enable: {
            type: 'boolean',
            values: [true],
            default: true
          },
          type: {
            type: 'string',
            values: ['sv'],
            default: 'sv'
          }
        }

        package_settings.level(0).should eq({
          name: 'sublime',
          template: {
            enable: {
              type: 'boolean',
              values: [true],
              default: true
            },
            type: {
              type: 'string',
              values: ['sv'],
              default: 'sv'
            }
          }
        })
      end
    end
  end

end
