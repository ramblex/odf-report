module ODFReport

class Report
  include Images

  def initialize(template_name = nil, io: nil)

    @template = ODFReport::Template.new(template_name, io: io)

    @texts = []
    @fields = []
    @tables = []
    @images = {}
    @image_names_replacements = {}
    @sections = []
    @frames = []

    yield(self) if block_given?

  end

  def add_field(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    field = Field.new(opts)
    @fields << field
  end

  def add_text(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    text = Text.new(opts)
    @texts << text
  end

  def add_table(table_name, collection, opts={})
    opts.merge!(:name => table_name, :collection => collection)
    tab = Table.new(opts)
    @tables << tab

    yield(tab)
  end

  def add_section(section_name, collection, opts={})
    opts.merge!(:name => section_name, :collection => collection)
    sec = Section.new(opts)
    @sections << sec

    yield(sec)
  end

  def add_image(name, path)
    @images[name] = path
  end

  def add_frame(frame_name, operations={}, opts={})
    opts.merge!(name: frame_name, ops: operations)
    @frames << Frame.new(opts)
  end

  def generate(dest = nil)

    @template.update_content do |file|

      file.update_files do |doc|

        @sections.each { |s| s.replace!(doc) }
        @tables.each   { |t| t.replace!(doc) }

        @texts.each    { |t| t.replace!(doc) }
        @fields.each   { |f| f.replace!(doc) }
        @frames.each { |f| f.replace!(doc) }

        find_image_name_matches(doc)
        avoid_duplicate_image_names(doc)

      end

      include_image_files(file)

    end

    if dest
      ::File.open(dest, "wb") {|f| f.write(@template.data) }
    else
      @template.data
    end

  end

end

end
