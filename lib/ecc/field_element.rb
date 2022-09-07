module ECC
  class FieldElement
    attr_accessor :num, :prime

    def initialize(num, prime)
      raise StandardError, "Num #{num} not in field range 0 to #{prime}" if num >= prime || num.negative?

      @num = num
      @prime = prime
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

      other.num == num && other.prime == prime
    end

    def +(other)
      raise StandardError, "Cannot add two numbers in different fields" if other.prime != prime

      sum = (num + other.num) % prime
      ECC::FieldElement.new(sum, prime)
    end

    def -(other)
      raise StandardError, "Cannot substract two numbers in different fields" if other.prime != prime

      sub = (num - other.num) % prime
      ECC::FieldElement.new(sub, prime)
    end

    def *(other)
      raise StandardError, "Cannot multiply two numbers in different fields" if other.prime != prime

      mult = (num * other.num) % prime
      ECC::FieldElement.new(mult, prime)
    end

    def /(other)
      raise StandardError, "Cannot divide two numbers in different fields" if other.prime != prime

      div = (num * self.class.pow(other.num, prime - 2, prime)) % prime
      ECC::FieldElement.new(div, prime)
    end

    def **(other)
      n = other % (prime - 1)
      result = self.class.pow(num, n, prime)
      ECC::FieldElement.new(result, prime)
    end
  end
end
