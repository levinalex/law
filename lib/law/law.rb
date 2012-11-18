class Law::Law
  attr_accessor :id
  attr_accessor :short_name
  attr_accessor :title

  def initialize
  end


  def inspect
    "law: #{id}"

  end

  def self.from_xml(xml)
    law = allocate
    law.id = xml.xpath("//dokumente/norm/metadaten/jurabk").first.text.strip

    law
  end

end
