FactoryGirl.define do
  factory :appliance_configuration_instance,
    class: 'Atmosphere::ApplianceConfigurationInstance' do |f|
    payload { Faker::Lorem.words(10).join(' ') }
  end
end