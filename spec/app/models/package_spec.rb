require 'spec_helper'

describe Package do

  describe 'Associations' do
    it { should have_and_belong_to_many(:app_md5s) }
  end

  describe '#dependencies' do
    let(:package) { described_class.create(dependencies: { a: 'b' }) }

    it 'is a json hash' do
      package.dependencies.should eq({ 'a' => 'b' })
    end
  end

end
