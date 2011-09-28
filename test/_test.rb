require File.expand_path('../teststrap', __FILE__)

context 'Rack::ESI' do

  __dirname__ = File.expand_path File.dirname(__FILE__)
  root = Pathname.new File.join(__dirname__, 'fixtures')
  opts = { :urls => ['/'], :root => root }

  setup { ESI.new Static.new(App.new, opts), skip: /raw/, :poolsize => 1 }

  context 'GET /raw.html' do
    setup { MockRequest.new(topic).get '/raw.html' }
    asserts('Content-Type') { topic.content_type }.equals 'text/html'
    should('not be altered') { topic.body == root.join('raw.html').read }
  end

  context 'GET /index.html' do
    setup { MockRequest.new(topic).get '/index.html' }

    asserts('Content-Type') { topic.content_type }.equals 'text/html'
    should('not have any ESI specific nodes') do
      html(topic.body).
      at('//e:*', 'e' => Rack::ESI::Processor::NAMESPACE).nil?
    end
    should('have meta replacement with content') do
      not html(topic.body).
      at("//meta[@name='replacement' and @content='content']").nil?
    end
  end

end
