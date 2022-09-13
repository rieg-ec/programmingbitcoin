require_relative "../helpers/instance_method_hook"

module ECC
  class Point
    # @TODO method hook that raises ArgumentError when points are not from the same curve
    # like a before_save :method1
    attr_accessor :x, :y, :a, :b

    def initialize(x, y, a, b)
      @x = x
      @y = y
      @a = a
      @b = b

      return if x.nil? && y.nil?

      raise ArgumentError, "#{x}, #{b} is not on the curve" if y**2 != x**3 + a * x + b
    end

    def ==(other)
      return false if other.nil?

      a == other.a && b == other.b && x == other.x && y == other.y
    end

    def +(other)
      raise_if_not_from_same_curve(other)

      return other if x.nil?
      return ECC::Point.new(x, y, a, b) if other.x.nil?

      return ECC::Point.new(nil, nil, a, b) if other.x == x && y != other.y
      return ECC::Point.new(nil, nil, a, b) if other.y == y && y.zero?

      if other.y == y
        s = (3 * x**2 + a) / 2 * y
        x3 = s**2 - 2 * x
        y3 = s * (x - x3) - y
      else
        s = (other.y - y) / (other.x - x)
        x3 = s**2 - x - other.x
        y3 = s * (x - x3) - y
      end

      ECC::Point.new(x3, -y3, a, b)
    end

    private

    def from_same_curve?(other)
      a = other.a || b == other.b
    end

    def raise_if_not_from_same_curve(other)
      raise ArgumentError, "#Points #{self}, #{other} are not in the same curve" unless from_same_curve?(other)
    end
  end
end
