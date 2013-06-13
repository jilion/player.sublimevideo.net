require 'spec_helper'

describe Loader do

  describe 'Associations' do
    it { should belong_to(:app_md5) }
  end

end
