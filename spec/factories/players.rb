FactoryBot.define do
  factory :player do
    room_id { create(:room).id }
    role { Player.roles.keys.sample }
    
    trait :authorized do
      session_token { SecureRandom.uuid }
    end
  end
end
