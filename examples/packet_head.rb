$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'command_lion'
require 'packetgen'
require 'pry'

CommandLion::App.run do

  name "Packet Head"
  version "1.0.0"
  description "Streaming captured packet headers straight to the command-line."

  command :capture do
    description "Capture from a given network interface ( default: #{Pcap.lookupdev} )."
    type :string
    default Pcap.lookupdev

    action do
      capture = Pcap.open_live(argument, options[:snaplen].argument, options[:promisc].argument, options[:buffer].argument)
      loop do
        while packet = capture.next
          begin
            puts PacketGen.parse(packet).headers.map(&:class).map {|h| h.to_s.split("::").last }.join(" - ")
          rescue # some error, yolo
            next
          end 
        end
      end
    end
    
    option :snaplen do
      default 65535
      type :integer
      description "Amount of data for each frame that is actually captured."
    end

    option :promisc do
      type :bool
      default true
      description "Capture all traffic received rather than only the frames the controller is meant to receive."
    end

    option :buffer do
      type :integer
      default 1
      description "Read time out in milliseconds when capturing packets, and a value of 0 means no time out."
    end
  end

end
