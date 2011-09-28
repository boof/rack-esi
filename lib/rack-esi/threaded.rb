require 'thread'
#require 'timeout'

class Rack::ESI

  class Finisher < Proc
    def self.wait(queue)
      finisher = new do |worker|
        puts "Finishing #{ worker.inspect }..."
        worker[:finish] = true
        queue.push finisher
      end

      # cast the first stone
      queue.push finisher

      # wait at the end
      queue.pop
    end
  end

  class Worker < Thread
    def initialize(queue)
      super do
        begin
          queue.pop[ self ]
        rescue => e
          puts e
        end until key? :finish
      end
    end
  end

  class Processor::Threaded < Processor
    def process_document(document)
      nodes = document.xpath '//e:*', 'e' => NAMESPACE

      countdown, main = nodes.length, Thread.current
      nodes.each do |node|
        esi.queue do
          process_node node
          main.run if (countdown -= 1).zero?
        end
      end
      # TODO prevent nesting depth bigger than poolsize
      Thread.stop if countdown > 0 # wait for worker
    end
  end

end
