require 'rails_helper'

RSpec.describe Board do  
  describe '.setup' do
    subject { Board.setup }

    it 'initializes instance' do
      expect(subject.squares.flatten.size).to eq 64 # 8 x 8
      expect(subject.squares.dig(3, 3)).to eq 'first'
      expect(subject.squares.dig(4, 4)).to eq 'first'
      expect(subject.squares.dig(3, 4)).to eq 'second'
      expect(subject.squares.dig(4, 3)).to eq 'second'
      expect(subject.movable_role).to eq 'first'
    end
  end

  describe '#calculate_movable_squares' do
    subject { Board.setup.calculate_movable_squares }
  
    context '初期状態の盤面で、先手が実行すると' do
      it { is_expected.to match_array [[2, 4], [3, 5], [4, 2], [5, 3]] }
    end
  end

  describe '#passable?' do
    context '初期状態の盤面で実行すると' do
      it { expect(Board.setup.passable?).to eq false }
    end

    context '打てる場所がない盤面で実行すると' do
      it 'returns true' do
        board = Board.new(
          squares: [ # 誰も打てない...
            ['second' , 'second' , 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral']
          ],
          movable_role: 'first',
        )
        expect(board.passable?).to eq true
      end
    end
  end

  describe '#apply' do
    context '初期状態の盤面で、x = 4, y = 2 に打つと' do
      let(:board) { Board.setup }

      it 'x = 4, y = 2 と x = 4, y = 3 が first になる' do
        expect {
          board.apply(x: 4, y: 2, pass: false)
        }.to change {
          [board.at(x: 4, y: 2), board.at(x: 4, y: 3)]
        }.from(
          ['neutral', 'second']
        ).to(
          ['first', 'first']
        )
      end

      it 'movable_role が first から second になる' do
        expect {
          board.apply(x: 4, y: 2, pass: false)
        }.to change {
          board.movable_role
        }.from(
          'first'
        ).to(
          'second'
        )
      end
    end

    context '初期状態の盤面で、x = 4, y = 2 に打つと' do
      let(:board) { Board.setup }

      it 'x = 4, y = 2 と x = 4, y = 3 が first になる' do
        expect {
          board.apply(x: 4, y: 2, pass: false)
        }.to change {
          [board.at(x: 4, y: 2), board.at(x: 4, y: 3)]
        }.from(
          ['neutral', 'second']
        ).to(
          ['first', 'first']
        )
      end

      context '盤面の端にコマがあるとき' do
        it '端に置けない' do
          board = Board.new(
            squares: [
              ['neutral', 'first'  , 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
              ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
              ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
              ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
              ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
              ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
              ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
              ['neutral', 'second' , 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral']
            ],
            movable_role: 'second',
          )

          expect { board.apply(x: 1, y: 1, pass: false) }.to raise_error(ArgumentError, /no_square_is_taken/)
        end
      end
    end

    context '手番が打てる手がない状態で、 pass: true を指定すると' do
      let(:passable_board) do
        board = Board.setup
        # first → second に置き換えて、真ん中の4マスが全部 second であり、他はすべて neutral である状態にする
        board.squares = board.squares.map { _1.map { |square| square == 'first' ? 'second' : square } }
        board
      end
      
      it '手番が入れ替わる' do
        expect { passable_board.apply(x: nil, y: nil, pass: true) }.to change { passable_board.movable_role }.from('first').to('second')
      end
    end
  end

  describe '#finished?' do
    context 'すべてのマスが埋まっているとき' do
      it 'returns true' do
        board = Board.new(
          squares: Array.new(8) { Array.new(8) { Board::ATTACKER_ROLES.sample } },
          movable_role: Board::ATTACKER_ROLES.sample,
        )

        expect(board.finished?).to eq true
      end
    end

    context '一部 neutral があるが、どちらも指せるマスがないとき' do
      it 'returns true' do
        board = Board.setup
        # first → second に置き換えて、真ん中の4マスが全部 second であり、他はすべて neutral である状態にする
        board.squares = board.squares.map { _1.map { |square| square == 'first' ? 'second' : square } }
        expect(board.finished?).to eq true
      end
    end

    context '初期状態の盤面に対して実行すると' do
      it 'returns false' do
        expect(Board.setup.finished?).to eq false
      end
    end

    context '手番が指せる手はないが、次の手番は指せる手があるとき' do
      it 'returns false' do
        board = Board.new(
          squares: [
            ['first'  , 'second' , 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral']
          ],
          movable_role: 'second',
        )

        expect(board.finished?).to eq false
      end
    end
  end

  describe '#winner' do
    context '初期状態の盤面に対して実行すると' do
      it 'returns nil' do
        expect(Board.setup.winner).to eq nil
      end
    end

    context '初期状態から1手指した状態に対して実行すると' do
      it 'returns first' do
        board = Board.setup
        board.apply(x: 4, y: 2, pass: false)
        expect(board.winner).to eq 'first'
      end
    end

    context '先手が全部取られた盤面に対して実行すると' do
      it 'returns second' do
        board = Board.new(
          squares: [
            ['second'  , 'second' , 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral'],
            ['neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral', 'neutral']
          ],
          movable_role: 'second',
        )

        expect(board.winner).to eq 'second'
      end
    end
  end
end
