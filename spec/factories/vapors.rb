# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :vapor do
    id 1
    path Rails.root.join('tmp', 'test-git-base-path').to_s
    default true
    tier 1

    after :create do |vapor|
      FileUtils.mkdir_p vapor.path
    end
  end

end
