$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'detagger'

def capture(*streams)
  begin
    result = StringIO.new
    streams.each { |stream| eval "$#{stream} = result" }
    yield
  rescue SystemExit
  ensure
    streams.each { |stream| eval("$#{stream} = #{stream.to_s.upcase}") }
  end
  result.string
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
