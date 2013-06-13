require 'spec_helper'

describe Package do

  context 'Factory' do
    subject { create(:package).reload }

    its(:name)          { should be_present }
    its(:version)       { should eq '1.0.0' }
    its(:dependencies)  { should eq({}) }
    it { should be_valid }
  end

  describe 'Associations' do
    it { should have_and_belong_to_many(:app_md5s) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:version) }
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
    let(:addons) { [stub(name: 'lightbox'), stub(name: 'logo')] }

    it 'retrieves all the latest stable packages for the given addons' do
      described_class.packages_from_addons(addons).should eq [@lightbox_package_1s, @logo_package_1s]
    end

    context 'given the "alpha" stage' do
      it 'retrieves all the packages for the given addons and stage' do
        described_class.packages_from_addons(addons, 'alpha').should eq [@lightbox_package_2a, @lightbox_package_1s, @lightbox_package_1b, @lightbox_package_1a, @logo_package_2b, @logo_package_2a, @logo_package_1s, @logo_package_1b, @logo_package_1a]
      end
    end

    context 'given the "beta" stage' do
      it 'retrieves all the packages for the given addons and stage' do
        described_class.packages_from_addons(addons, 'beta').should eq [@lightbox_package_1s, @lightbox_package_1b, @logo_package_2b, @logo_package_1s, @logo_package_1b]
      end
    end

    context 'given the "stable" stage' do
      it 'retrieves all the packages for the given addons and stage' do
        described_class.packages_from_addons(addons, 'stable').should eq [@lightbox_package_1s, @logo_package_1s]
      end
    end
  end

  describe '#dependencies' do
    let(:package) do
      begin
        create(:package, dependencies: { a: 'b' })
      rescue => ex
        puts ex.backtrace
      end
    end

    it 'is a json hash' do
      package.dependencies.should eq({ 'a' => 'b' })
    end
  end

end
