class PlayersController < ApplicationController  
  def authorize
    Player.transaction do
      player = Player.lock.find_by!(room_id: params[:room_id], id: params[:id])
      # 認証済のプレイヤーがこのエンドポイントを間違えて叩いてしまったときは、単に処理をスキップしてリダイレクトすれば良い
      # 認証済でないプレイヤーが入ってきたとしても、リダイレクト先で認証がコケてエラーになるので、ここでは単に処理をスキップして問題ない
      break if player.taken?

      player.authorize(session)
      player.save!
    end

    redirect_to second_attacker_room_path(id: params[:room_id])
  end
end
