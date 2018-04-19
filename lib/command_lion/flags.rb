module CommandLion

  class Flags < Base
    simple_attrs :short, :long
  
		def all
			[@short, @long].reject { |v| v.nil? }
		end
	end

end
