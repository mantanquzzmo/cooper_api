FactoryBot.define do
  factory :performance_data, class: 'PerformanceData' do
    user
    data { "" }
  end
end
