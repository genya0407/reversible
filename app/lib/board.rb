class Board < Struct.new(:squares, :movable_role, keyword_init: true)
  ATTACKER_ROLES = %w[first_attacker second_attacker]
  SQUARE_STATES = %w[neutral] + ATTACKER_ROLES

  def self.setup # TODO: 名前が不適切な気がする。初期化 的な名前にしたい。
    self.new(
      squares: Array.new(8) do |x|
        Array.new(8) do |y|
          if x.between?(3, 4) && y.between?(3, 4)
            x == y ? 'first_attacker' : 'second_attacker'
          else
            'neutral'
          end
        end
      end,
      movable_role: 'first_attacker', # 一番最初は first が攻撃できるようにする
    )
  end

  def calculate_movable_squares
    movable_squares = []
    squares.each.with_index do |rows, y|
      rows.each.with_index do |row, x|
        unless calculate_unapplicable_reason(x: x, y: y, pass: false)
          movable_squares << [x, y]
        end
      end
    end
    movable_squares
  end

  def passable?
    calculate_movable_squares.empty?
  end

  def apply(x:, y:, pass:)
    unapplicable_reason = calculate_unapplicable_reason(x: x, y: y, pass: pass)
    raise ArgumentError, unapplicable_reason.to_s if unapplicable_reason

    unless pass
      reverse_candidates = calculate_reversible_squares(x: x, y: y)
      reverse_candidates.each do |x, y|
        squares[y][x] = movable_role
      end
      squares[y][x] = movable_role
    end

    self.movable_role = (ATTACKER_ROLES - [self.movable_role]).first
  end

  def ascii_art
    squares.map do |rows|
      rows.map do |row|
        case row
        when 'neutral'
          '□'
        when 'first_attacker'
          '△'
        when 'second_attacker'
          '●'
        end
      end.join
    end.join("\n")
  end

  def finished?
    # 手番が指せる手があれば、まだ終わってない
    return false unless calculate_movable_squares.empty?

    # 手番が指せる手がない場合、手番にパスさせて、次の手番も指せる手がない場合は終了しているとみなす
    copy_board = self.deep_dup
    copy_board.apply(x: nil, y: nil, pass: true)
    return false unless copy_board.calculate_movable_squares.empty?

    true
  end

  def winner
    if square_count_by_role.values.uniq.size == 1
      # 引き分け
      nil
    else
      square_count_by_role.max_by { _2 }.first
    end
  end

  def square_count_by_role
    hash = ATTACKER_ROLES.map { [_1, 0] }.to_h
    squares.flatten.select { ATTACKER_ROLES.include?(_1) }.each do |square|
      hash[square] += 1
    end
    hash
  end

  def at(x:, y:)
    squares.dig(y, x)
  end

  private

  def directions
    [-1, 0, 1].product([-1, 0, 1]).reject { |d| d == [0, 0] }
  end

  def calculate_unapplicable_reason(x:, y:, pass:)
    return :movable_square_exists if pass && !calculate_movable_squares.empty?
    return nil if pass

    return :out_of_board if at(x: x, y: y).nil?
    return :already_taken if at(x: x, y: y) != 'neutral'
    reversible_squares = calculate_reversible_squares(x: x, y: y)
    return :no_square_is_taken if reversible_squares.empty?

    nil
  end

  def calculate_reversible_squares(x:, y:)
    target_role = (ATTACKER_ROLES - [movable_role]).first

    reversible_squares = []
    directions.each do |direction|
      cx, cy = x, y
      dx, dy = direction
      reverse_candidates = []

      loop do
        cx, cy = cx + dx, cy + dy

        break unless cx.between?(0, 7) && cy.between?(0, 7)

        case squares.dig(cy, cx)
        when nil, 'neutral'
          reverse_candidates = []
          break
        when target_role
          reverse_candidates << [cx, cy]
        when movable_role
          reversible_squares.concat(reverse_candidates)
          break
        else
          raise "unexpected square: #{at(cx, cy).inspect} in #{inspect}"
        end
      end
    end

    reversible_squares
  end
end
