module Rack
  module MiddlewareInjector
    InjectError = Class.new(StandardError)
    
    def use(middleware, options = {})
      if respond_to?(:call)
        app = method(:call)
        app = middleware.new(app, options)
        class << self; method(:define_method); end.call(:call) do |env|
          app.call(env)
        end
      elsif respond_to?(:instance_methods) && instance_methods.include?('call')
        app = instance_method(:call)
        define_method(:call) do |env|
          middleware.new(app.bind(self), options).call(env)
        end
      else
        raise InjectError, 'could not find #call or .call'
      end
    end
  end
end
