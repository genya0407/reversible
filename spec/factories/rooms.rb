FactoryBot.define do
  factory :room do
    id { SecureRandom.uuid }
    board_json { Board.setup.to_h.to_json }

    trait :with_players do
      after(:create) do |room|
        room.players.create!(role: :first_attacker)
        room.players.create!(role: :second_attacker)
      end
    end
  end
end
