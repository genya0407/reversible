require 'rails_helper'

RSpec.describe "Rooms", type: :request do
  describe "POST create" do
    context '実行したとき' do
      it 'redirect' do
        post '/rooms'
        room = Room.first
        expect(response).to redirect_to("/rooms/#{room.id}/first_attacker")
      end

      it 'creates a room' do
        expect {
          post '/rooms'
        }.to change { Room.count }.from(0).to(1)
      end
    end
  end

  describe "GET first_attacker" do
    context 'room 作成者が実行したとき' do
      before do
        post '/rooms' # session をセット
      end
      
      it 'success' do
        room = Room.first # before で作られた room
        # session を持ってるので叩ける
        get "/rooms/#{room.id}/first_attacker"
        expect(response.status).to eq 200
      end
    end

    context 'room 作成者以外が実行したとき' do
      let!(:room) { FactoryBot.create(:room, :with_players) }
      
      it 'redirected to show' do
        get "/rooms/#{room.id}/first_attacker"
        expect(response).to redirect_to("/rooms/#{room.id}")
      end
    end
  end

  describe "GET second_attacker" do
    context 'authorize していないとき' do
      let!(:room) { FactoryBot.create(:room, :with_players) }

      it 'redirected to show' do
        get "/rooms/#{room.id}/second_attacker"
        expect(response).to redirect_to("/rooms/#{room.id}")
      end
    end

    context 'authorize しているとき' do
      let!(:room) { FactoryBot.create(:room, :with_players) }

      before do
        post "/rooms/#{room.id}/players/#{room.second_attacker.id}/authorize"
      end

      it 'success' do
        get "/rooms/#{room.id}/second_attacker"
        expect(response.status).to eq 200
      end
    end
  end

  describe "GET show" do
    context 'authorize してないとき' do
      let!(:room) { FactoryBot.create(:room, :with_players) }

      it 'success' do
        get "/rooms/#{room.id}"
        expect(response.status).to eq 200
      end
    end

    context 'first_attacker として authorize しているとき' do
      before do
        post "/rooms"
      end

      it 'redirect to first_attacker' do
        get "/rooms/#{Room.first.id}"
        expect(response).to redirect_to("/rooms/#{Room.first.id}/first_attacker")
      end
    end

    context 'second_attacker として authorize しているとき' do
      let!(:room) { FactoryBot.create(:room, :with_players) }

      before do
        post "/rooms/#{room.id}/players/#{room.second_attacker.id}/authorize"
      end

      it 'redirect to second_attacker' do
        get "/rooms/#{Room.first.id}"
        expect(response).to redirect_to("/rooms/#{Room.first.id}/second_attacker")
      end
    end
  end

  describe "GET show" do
    context 'authorize してないとき' do
      let!(:room) { FactoryBot.create(:room, :with_players) }

      it 'success' do
        get "/rooms/#{room.id}/watcher"
        expect(response.status).to eq 200
      end
    end

    context 'first_attacker として authorize しているとき' do
      before do
        post "/rooms"
      end

      it 'success' do
        get "/rooms/#{Room.first.id}/watcher"
        expect(response.status).to eq 200
      end
    end

    context 'second_attacker として authorize しているとき' do
      let!(:room) { FactoryBot.create(:room, :with_players) }

      before do
        post "/rooms/#{room.id}/players/#{room.second_attacker.id}/authorize"
      end

      it 'success' do
        get "/rooms/#{room.id}/watcher"
        expect(response.status).to eq 200
      end
    end
  end
end
