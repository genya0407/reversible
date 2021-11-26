class MovesController < ApplicationController
  def create
    me = Player.find_by!(room_id: params[:room_id], id: params[:player_id])
    raise 'authentication failed' unless me.authenticate?(session)

    room = apply_move(me: me)

    # 相手に通知
    players_in_db = Player.where(room_id: room.id, id: (room.player_ids - [me.id]))
    (players_in_db + [room.watcher]).each do |target|
      room.broadcast_update_to(target, :board, target: "room-#{room.id}", partial: 'board', locals: { room: room, player: target })
    end

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.update("room-#{room.id}", partial: 'board', locals: { room: room, player: me })
        )
      end
    end
  end

  private
  def apply_move(me:)
    room = nil
    Room.transaction do
      room = Room.lock.find(params[:room_id])

      existing_move = Move.find_by(player_id: me.id, room_id: params[:room_id], request_id: params[:request_id])
      return room if existing_move # 再送

      move = Move.new(
        player_id: me.id, room_id: params[:room_id], pass: !!params[:pass], request_id: params[:request_id],
        x: params[:x], y: params[:y], attacker_role: me.role
      )
      move.save!

      board = room.board

      raise 'invalid player' unless board.movable_role == move.attacker_role

      board.apply(x: move.x, y: move.y, pass: move.pass?)
      room.board_json = board.to_h.to_json
      room.save!
    end

    room
  end
end
