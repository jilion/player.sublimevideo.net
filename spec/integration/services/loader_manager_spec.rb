require 'spec_helper'

describe LoaderManager do
  let(:app) { create(:app) }
  let(:service) { described_class.new('abcd1234', app, 'stable') }

  describe '#update' do
    context 'with non-existing loader' do
      it 'creates an app bundle' do
        expect { service.update }.to change(Loader, :count).by(1)
      end

      it 'returns true' do
        service.update.should be_true
      end
    end

    context 'with existing loader' do
      before { service.update }

      it 'does not create an app bundle' do
        expect { service.update }.to_not change(Loader, :count)
      end
    end
  end

  describe '#delete' do
    context 'with a non-existing loader' do
      it 'does nothing' do
        expect { service.delete }.to_not change(Loader, :count)
      end
    end

    context 'with existing loader' do
      before { service.update }

      it 'destroy the loader' do
        expect { service.delete }.to change(Loader, :count).by(-1)
      end
    end
  end

end
