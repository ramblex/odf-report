module ODFReport

  class Table
    include Nested

    def initialize(opts)
      @name             = opts[:name]
      @collection_field = opts[:collection_field]
      @collection       = opts[:collection]

      @fields = []
    end

    def replace!(doc, row = nil)
      table = find_table_node(doc)
      return unless table.present?

      template_row = table.xpath("./table:table-row")&.first
      return unless template_row.present?

      @collection = get_collection_from_item(row, @collection_field) if row
      @collection.each do |data_item|
        new_node = template_row.dup
        @fields.each { |f| f.replace!(new_node, data_item) }
        table.add_child(new_node)
      end

      template_row.remove
    end

  private
    def template_length
      @tl ||= @template_rows.size
    end

    def find_table_node(doc)
      tables = doc.xpath(".//table:table[@table:name='#{@name}']")
      tables.empty? ? nil : tables.first
    end
  end
end
