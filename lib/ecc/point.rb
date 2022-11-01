require_relative "../helpers/encoding"

module ECC
  class Point
    include Helpers::Encoding
    attr_reader :x, :y, :a, :b

    def initialize(x, y, a, b)
      @x = x
      @y = y
      @a = a
      @b = b

      return if x.nil? && y.nil?

      raise ArgumentError, "#{x}, #{y} is not on the curve" if y**2 != x**3 + a * x + b
      # rescue ArgumentError
      #   binding.pry
    end

    def to_s
      "Point(#{@x || "nil"}, #{@y || "nil"})_#{@a}_#{@b}"
    end

    def coerce(other)
      [self, other]
    end

    def ==(other)
      return false if other.nil?

      a == other.a && b == other.b && x == other.x && y == other.y
    end

    def *(other)
      return scalar_multiply(other) if other.is_a? Integer
    end

    def +(other)
      raise_if_not_from_same_curve(other)

      return other if x.nil?
      return self if other.x.nil?

      return self.class.new(nil, nil, a, b) if other.x == x && y != other.y

      return self.class.new(nil, nil, a, b) if self == other && y.zero?

      self == other ? add_same_points : add_different_points(other)
    end

    private

    def add_different_points(other)
      slope = (other.y - @y) / (other.x - @x)
      x = slope**2 - @x - other.x
      y = slope * (@x - x) - @y

      self.class.new(x, y, @a, @b)
    end

    def add_same_points
      slope = (3 * @x**2 + @a) / (2 * @y)
      x = slope**2 - 2 * @x
      y = slope * (@x - x) - @y

      self.class.new(x, y, @a, @b)
    end

    def scalar_multiply(num)
      coef = num
      current = self
      result = self.class.new(nil, nil, a, b)
      while coef.positive?
        result += current if coef & 1 == 1
        current += current
        coef >>= 1
      end
      result
    end

    def from_same_curve?(other)
      a == other.a || b == other.b
    end

    def raise_if_not_from_same_curve(other)
      raise ArgumentError, "#Points #{self}, #{other} are not in the same curve" unless from_same_curve?(other)
    end
  end
end
