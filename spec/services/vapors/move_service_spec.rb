require 'spec_helper'

describe Vapors::MoveService do
  let(:vapor) { create(:vapor) }
  let(:extra_vapor) { create(:vapor, id: 2, path: "/tmp") }
  let(:project) { create(:project) }
  before do
    Vapor.destroy_all
    vapor; extra_vapor
  end
  after do
    `rm -rf /tmp/test_git_repo.git`
  end
  it 'should initialize' do
    Vapors::BaseVaporService.new(vapor).should_not raise_error
  end

  it 'should raise an error if there are not enough vapors' do
    Vapor.destroy_all
    expect{ Vapors::BaseVaporService.new(vapor) }.to raise_error(Vapors::BaseVaporService::VaporCountError)
  end

  # Breaks stuff
  # it 'should move projects from one vapor to another' do
  #   @project = project
  #   repo_path = "#{File.join @project.vapor.path, @project.path_with_namespace}.git"
  #   Repository.any_instance.stub(:path).and_return repo_path
  #   FileUtils.mkdir_p File.join(@project.vapor.path, @project.namespace.path)
  #   `git init --bare #{repo_path}`
  #   Vapors::MoveService.new(extra_vapor).move(@project)
  #
  # end

end
