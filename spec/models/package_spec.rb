require 'spec_helper'

describe Package do

  context 'Factory' do
    subject { create(:package).reload }

    its(:name)          { should be_present }
    its(:version)       { should eq '1.0.0' }
    its(:dependencies)  { should eq({}) }
    its(:settings)  { should eq({}) }
    it { should be_valid }
  end

  describe 'Associations' do
    it { should have_and_belong_to_many(:app_bundles) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:version) }
    it { should validate_uniqueness_of(:version).scoped_to(:name) }
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

  describe '#dependencies' do
    let(:package) { create(:package, dependencies: { a: 'b' }) }

    it 'is a json hash' do
      package.dependencies.should eq({ 'a' => 'b' })
    end
  end

  describe '#settings' do
    let(:package) { create(:package, settings: { a: 'b' }) }

    it 'is a json hash' do
      package.settings.should eq({ 'a' => 'b' })
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
#
# Indexes
#
#  index_packages_on_name              (name)
#  index_packages_on_name_and_version  (name,version) UNIQUE
#

