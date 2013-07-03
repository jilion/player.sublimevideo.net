require 'spec_helper'

describe Package do

  context 'Factory' do
    subject { create(:package) }

    its(:name)          { should be_present }
    its(:version)       { should be_present }
    its(:zip)           { should be_present }
    its(:dependencies)  { should be_present }
    its(:settings)      { should be_present }
    it { should be_valid }
  end

  describe 'Associations' do
    it { should have_and_belong_to_many(:apps) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:zip) }
    it { should validate_uniqueness_of(:version).scoped_to(:name) }
  end

  describe 'before_create' do
    let(:package) { create(:sony_player_1_0_0) }

    it 'sets the name from the package.json' do
      package.name.should eq 'sony-player'
    end

    it 'sets the version from the package.json' do
      package.version.should eq '1.0.0'
    end

    it 'sets the dependencies from the package.json' do
      package.dependencies.should eq({
        'classic-player-controls' => '1.0.0'
      })
    end

    it 'sets the settings from the package.json' do
      package.settings.should eq({
        'controls' => {
          'standard' => {
            'enable' => {
              'type' => 'boolean',
              'values' => [true, false],
              'default' => true
            }
          }
        },
        'subtitles' => {
          'standard' => {
            'enable' => {
              'type' => 'boolean',
              'values' => [true],
              'default' => true
            },
            'language' => {
              'type' => 'string',
              'values' => ['en'],
              'default' => 'en'
            }
          },
          'premium' => {
            'enable' => {
              'type' => 'boolean',
              'values' => [true],
              'default' => true
            },
            'language' => {
              'type' => 'string',
              'values' => ['en', 'fr'],
              'default' => 'en'
            }
          }
        }
      })
    end
  end

  describe '.packages_from_addons' do
    before do
      @lightbox_package_1a = create(:package, name: 'lightbox', version: '1.0.0-alpha')
      @lightbox_package_1b = create(:package, name: 'lightbox', version: '1.0.0-beta')
      @lightbox_package_1s = create(:package, name: 'lightbox', version: '1.0.0')
      @lightbox_package_2a = create(:package, name: 'lightbox', version: '2.0.0-alpha')
      @logo_package_1a     = create(:package, name: 'logo', version: '1.0.0-alpha')
      @logo_package_1b     = create(:package, name: 'logo', version: '1.0.0-beta')
      @logo_package_1s     = create(:package, name: 'logo', version: '1.0.0')
      @logo_package_2a     = create(:package, name: 'logo', version: '2.0.0-alpha')
      @logo_package_2b     = create(:package, name: 'logo', version: '2.0.0-beta')
    end
    let(:addon_names) { %w[lightbox logo] }

    it 'retrieves all the latest stable packages for the given addons' do
      described_class.packages_from_addons('classic', addon_names).should eq [@lightbox_package_1s, @logo_package_1s]
    end

    context 'given the "alpha" stage' do
      it 'retrieves all the packages for the given addons and stage' do
        described_class.packages_from_addons('classic', addon_names, 'alpha').should eq [@lightbox_package_2a, @lightbox_package_1s, @lightbox_package_1b, @lightbox_package_1a, @logo_package_2b, @logo_package_2a, @logo_package_1s, @logo_package_1b, @logo_package_1a]
      end
    end

    context 'given the "beta" stage' do
      it 'retrieves all the packages for the given addons and stage' do
        described_class.packages_from_addons('classic', addon_names, 'beta').should eq [@lightbox_package_1s, @lightbox_package_1b, @logo_package_2b, @logo_package_1s, @logo_package_1b]
      end
    end

    context 'given the "stable" stage' do
      it 'retrieves all the packages for the given addons and stage' do
        described_class.packages_from_addons('classic', addon_names, 'stable').should eq [@lightbox_package_1s, @logo_package_1s]
      end
    end
  end

  describe '#title' do
    let(:package) { create(:sony_player_1_0_0) }

    it 'concatenates the name and version' do
      package.title.should eq "#{package.name}-#{package.version}"
    end
  end

  describe '#main_file' do
    let(:package) { create(:sony_player_1_0_0) }

    it 'returns the main JS file' do
      package.main_file do |main_file|
        main_file.read.gsub(/\s+\Z/, '').should eq <<-EOF.gsub(/^\s+/, '').gsub(/\s+\Z/, '')
        // sony-player 1.0.0
      EOF
      end
    end
  end

  describe '#assets' do
    let(:package) { create(:sony_player_1_0_0) }

    it 'returns an array of assets' do
      package.assets { |assets| assets.should have(1).item }
    end

    it 'returns a hash with 2 keys: "name" & "file"' do
      package.assets do |assets|
        assets.each do |asset|
          asset[:name].should eq 'brand.png'
          asset[:file].should be_a Tempfile
        end
      end
    end
  end

end

# == Schema Information
#
# Table name: packages
#
#  created_at   :datetime
#  dependencies :json
#  id           :integer          not null, primary key
#  name         :string(255)
#  settings     :json
#  updated_at   :datetime
#  version      :string(255)
#  zip          :string(255)
#
# Indexes
#
#  index_packages_on_name              (name)
#  index_packages_on_name_and_version  (name,version) UNIQUE
#

