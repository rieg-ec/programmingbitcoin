module ECC
  class FieldElement
    attr_reader :num, :prime

    def initialize(num, prime)
      raise StandardError, "Num #{num} not in field range 0 to #{prime}" if num >= prime || num.negative?

      @num = num
      @prime = prime
    end

    def to_s
      "FieldElement(#{@num}, #{@prime})"
    end

    def coerce(other)
      [self, other]
    end

    def zero?
      @num.zero?
    end

    def -@
      self.class.new(-num, @prime)
    end

    def self.pow(number, exponent, modulo = nil)
      raise StandardError, "operation for exponent 0 not defined" if exponent.zero? && number.zero?
      raise StandardError, "operation not defined for negative exponent" if exponent.negative?

      return 1 if exponent.zero?

      result = number
      (exponent - 1).times do
        result = (result * number)
        result = result % modulo if modulo
      end
      result = result % modulo if modulo
      result
    end

    def ==(other)
      return false if other.nil?

      other.num == @num && other.prime == @prime
    end

    def +(other)
      raise StandardError, "Cannot add two numbers in different fields" if other.prime != @prime

      sum = (@num + other.num) % @prime
      self.class.new(sum, @prime)
    end

    def -(other)
      raise StandardError, "Cannot substract two numbers in different fields" if other.prime != @prime

      sub = (@num - other.num) % @prime
      self.class.new(sub, @prime)
    end

    def *(other)
      return self.class.new((other * @num) % @prime, @prime) if other.is_a? Integer

      raise StandardError, "Cannot multiply two numbers in different fields" if other.prime != @prime

      mult = (@num * other.num) % @prime
      self.class.new(mult, @prime)
    end

    def /(other)
      raise StandardError, "Cannot divide two numbers in different fields" if other.prime != @prime

      # too slow
      # div = (num * self.class.pow(other.num, prime - 2, prime)) % prime
      inverse = other**-1
      self * inverse
    end

    def **(exponent)
      # taken from https://github.com/jgmontoya/programmingbitcoin-ruby/blob/master/lib/ecc/field_element.rb#:~:text=end-,def%20**(exponent),-positive_exponent%20%3D%20exponent
      positive_exponent = exponent % (@prime - 1)
      num = @num.pow(positive_exponent, @prime)
      self.class.new(num, @prime)
    end
  end
end
