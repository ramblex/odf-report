module ODFReport
  class Field

    def initialize(opts, &block)
      @name = opts[:name]
      @data_field = opts[:data_field]

      unless @value = opts[:value]

        if block_given?
          @block = block

        else
          @block = lambda { |item| self.extract_value(item) }
        end

      end

    end

    def replace!(content, data_item = nil)
      val = get_value(data_item)
      content.xpath("//text:user-field-decl[@text:name='#{@name}']").each do |node|
        node['office:string-value'] = val
      end

      content.xpath("//*[@form:name='#{@name}']").each do |node|
        node['form:current-value'] = sanitize(val)
        node['form:value'] = sanitize(val)
      end
    end

    def get_value(data_item = nil)
      @value || @block.call(data_item) || ''
    end

    def extract_value(data_item)
      return unless data_item

      key = @data_field || @name

      if data_item.is_a?(Hash)
        data_item[key] || data_item[key.to_s.downcase] || data_item[key.to_s.upcase] || data_item[key.to_s.downcase.to_sym]

      elsif data_item.respond_to?(key.to_s.downcase.to_sym)
        data_item.send(key.to_s.downcase.to_sym)

      else
        raise "Can't find field [#{key}] in this #{data_item.class}"

      end

    end

    private

    def sanitize(txt)
      txt = html_escape(txt)
      txt = odf_linebreak(txt)
      txt
    end

    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }

    def html_escape(s)
      return "" unless s
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end

    def odf_linebreak(s)
      return "" unless s
      s.to_s.gsub("\n", "<text:line-break/>")
    end



  end
end
