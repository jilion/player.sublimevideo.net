require 'spec_helper'

describe AppMd5 do

  describe 'Associations' do
    it { should have_and_belong_to_many(:packages) }
    it { should have_one(:loader) }
  end

end
