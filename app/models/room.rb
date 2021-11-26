class Room < ApplicationRecord
  has_many :moves
  has_many :players

  validates :board_json, presence: true

  include Turbo::Broadcastable

  def first_attacker
    @first_attacker ||= players.find_by!(role: :first_attacker)
  end

  def second_attacker
    @second_attacker ||= players.find_by!(role: :second_attacker)
  end

  def board
    JSON.parse(board_json, object_class: Board)
  end

  def watcher
    Player.new(id: 'watcher', role: 'watcher', room_id: self.id)
  end

  def player_ids
    (players + [watcher]).map(&:id)
  end
end
