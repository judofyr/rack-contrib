require 'test/spec'
require 'rack/mock'
require 'rack/contrib/middleware_injector'

context "Rack::MiddlewareInjector" do
  middleware = Class.new do
    def initialize(app, options = {})
      @app = app
    end
    
    def call(env)
      "Middleware"
    end
  end
  
  specify "should inject when .call" do
    app = lambda { |env| "App" }
    app.extend(Rack::MiddlewareInjector)
    
    app.call({}).should.equal "App"
    app.use(middleware)
    app.call({}).should.equal "Middleware"
  end
  
  specify "should inject when #call" do
    app = Class.new do
      def call(env)
        "App"
      end
    end
    app.extend(Rack::MiddlewareInjector)
    
    app.new.call({}).should.equal "App"
    app.use(middleware)
    app.new.call({}).should.equal "Middleware"
  end
  
  specify "should fail otherwise" do
    app = Object.new
    app.extend(Rack::MiddlewareInjector)
    
    should.raise(Rack::MiddlewareInjector::InjectError) { app.use(middleware) }
  end
end
