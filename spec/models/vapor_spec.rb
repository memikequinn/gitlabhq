require 'spec_helper'

describe Vapor do
  let(:fake_vapor) { double(:vapor) }
  let(:extra_vapor) { create(:vapor, id: 2, path: "/tmp") }
  let(:vapor) { create(:vapor) }
  before do
    Vapor.destroy_all
  end
  it 'should show free space' do
    vapor.free_space.should be_a_kind_of(Integer)
  end

  it 'should return a usage' do
    vapor.usage.should be_a_kind_of(Integer)
  end

  it 'should throw an error when the path is not there' do
    Vapor.any_instance.stub(:path).and_return('/tmp/does_not_exist')
    expect { fake_vapor.ensure_dir_exists }.to raise_exception
  end

  it 'should find a vapor thats large enough' do
    # initialize vapors
    vapor; extra_vapor
    Vapor.any_instance.stub(:free_space).and_return(1000000)
    Vapor.any_instance.stub(:usage).and_return(1)
    vapor.big_enough.should_not be_nil
  end

  it 'should move projects off when deleted' do
    # The rest of this stuff is tested in the service
    expect(vapor).to receive(:move_off_projects)
    vapor.destroy
  end

end
