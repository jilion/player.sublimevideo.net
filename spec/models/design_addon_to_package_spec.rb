require "spec_helper"

describe DesignAddonToPackage do

  describe '.package' do
    context 'classic design' do
      let(:design) { 'classic' }

      it { described_class.package(design, 'controls').should eq 'classic-player-controls' }
      it { described_class.package(design, 'lightbox').should eq 'lightbox' }
      it { described_class.package(design, 'logo').should eq 'logo' }
    end

    context 'flat design' do
      let(:design) { 'flat' }

      it { described_class.package(design, 'controls').should eq 'player-controls' }
      it { described_class.package(design, 'lightbox').should eq 'lightbox' }
      it { described_class.package(design, 'logo').should eq 'logo' }
    end

    context 'light design' do
      let(:design) { 'light' }

      it { described_class.package(design, 'controls').should eq 'player-controls' }
      it { described_class.package(design, 'lightbox').should eq 'lightbox' }
      it { described_class.package(design, 'logo').should eq 'logo' }
    end

    context 'sony design' do
      let(:design) { 'sony' }

      it { described_class.package(design, 'controls').should eq 'sony-player' }
      it { described_class.package(design, 'lightbox').should eq 'sony-player' }
      it { described_class.package(design, 'logo').should eq 'sony-player' }
    end
  end

end
