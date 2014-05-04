class AdminVapors < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedActiveTab

  Given 'I sign in as an admin' do
    @admin = User.admins.first
  end

  Given 'system has users' do
    @users = User.all
  end

  Given 'system has vapors' do
    @vapors = [create(:vapor)]
  end

  Given 'system has projects' do
    @projects = Project.all
  end

  Then 'active main tab should be Vapors' do
    ensure_active_main_tab('Vapors')
    @vapors = create(:vapor)
  end

  Then 'I visit admin vapors page' do
    @vapors = Vapor.all
  end

  Then 'I should see all vapors' do
    @vapors = Vapor.all
    @vapors.count.should > 0
  end
end
