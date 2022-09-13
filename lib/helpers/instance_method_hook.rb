module InstanceMethodHook
  module ClassMethods
    def validate(*methods, with:)
      methods.each do |method_name|
        method = instance_method(method_name)
        define_method(method_name) do |*args, &block|
          method.bind(self).call(*args, block)
        end
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
