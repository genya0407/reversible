class Move < ApplicationRecord
  belongs_to :room
  belongs_to :player

  validates :attacker_role, inclusion: { in: Board::ATTACKER_ROLES }
  validates :x, numericality: { only_integer: true }, unless: :pass?
  validates :y, numericality: { only_integer: true }, unless: :pass?
end
