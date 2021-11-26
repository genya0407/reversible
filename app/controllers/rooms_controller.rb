class RoomsController < ApplicationController
  def index

  end

  def show
    @room = Room.find(params[:id])

    if @room.first_attacker.authenticate?(session)
      redirect_to action: :first_attacker, id: @room.id
      return
    end

    if @room.second_attacker.authenticate?(session)
      redirect_to action: :second_attacker, id: @room.id
      return
    end

    @second_attacker = @room.second_attacker
  end

  def watcher
    @room = Room.find(params[:id])
    @me = @room.watcher
  end

  def first_attacker
    @room = Room.find(params[:id])
    @me = @room.first_attacker
    @target = @room.second_attacker

    unless @me.authenticate?(session)
      redirect_to action: :show
    end
  end

  def second_attacker
    @room = Room.find(params[:id])
    @me = @room.second_attacker

    unless @me.authenticate?(session)
      redirect_to action: :show
    end
  end

  def create
    room_id = SecureRandom.uuid

    room = Room.new(
      id: room_id,
      board_json: Board.setup.to_h.to_json,
    )
    first_attacker = room.players.build(role: :first_attacker)
    room.players.build(role: :second_attacker)

    first_attacker.authorize(session)

    room.save!

    redirect_to action: :first_attacker, id: room.id
  end
end
