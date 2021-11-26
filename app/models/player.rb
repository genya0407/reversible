class Player < ApplicationRecord
  class AlreadyTakenError < StandardError; end
  class NotTakenError < StandardError; end

  belongs_to :room

  enum role: {
    first_attacker: 1,
    second_attacker: 2,
    watcher: 3,
  }

  validates :role, inclusion: { in: roles.keys }

  # token を発行して、自身と session に set する
  def authorize(session) # TODO: 用語が間違ってる感がすごい
    raise AlreadyTakenError if taken?

    self.session_token = session[:session_token] = SecureRandom.uuid
  end

  # session の値と自身の token が一致しているか確認する
  def authenticate?(session)
    self.taken? && session[:session_token] == self.session_token
  end

  def taken? = session_token.present?
end
