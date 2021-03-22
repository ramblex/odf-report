module ODFReport
  class Frame
    def initialize(opts)
      @name = opts[:name]
      @operations = opts[:ops]
    end

    def replace!(content, data_item = nil)
      frames = content.xpath("//draw:frame[@draw:name='#{@name}']")
	
      frames.each do |frame|
	style_name = frame.attribute('style-name')
	style = content.xpath("//style:style[@style:name='#{style_name}']/style:graphic-properties")
	@operations.each do |op, value|      
	  style.attribute(op)&.value = value
	end
      end
    end
  end
end
