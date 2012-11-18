class Law::Law
  attr_accessor :uid
  attr_accessor :short_name
  attr_accessor :title

  def initialize_from_xml(xml)
    @sections = []

    doc_meta = xml.at_xpath(%Q(dokumente/norm[/dokumente/@doknr=@doknr]/metadaten))

    self.uid = doc_meta.at_xpath(%Q(./jurabk)).text
    self.short_name = doc_meta.xpath(%Q(string(./kurzue)))

    xml.xpath(%Q(dokumente/norm[/dokumente/@doknr!=@doknr])).each do |norm|
      if norm.at_xpath(%Q(./metadaten/gliederungseinheit))
        sn = norm.xpath("string(./metadaten/gliederungseinheit/gliederungskennzahl)")
        bez = norm.xpath("string(./metadaten/gliederungseinheit/gliederungsbez)")
        title = norm.xpath("string(./metadaten/gliederungseinheit/gliederungstitel)")

        self.add_section(sn, bez, title)
      end
    end
  end

  def add_section(sid, bez, txt)
    txt = txt.gsub(/\s+/, " ")
    @sections << [sid, bez, txt]
  end


  def inspect
    s = "law: #{uid} - #{short_name}\n" +
      @sections.map { |s| "\t" + s.join(" - ") }.join("\n")

      s.strip
  end

  def self.from_xml(xml)
    law = allocate
    law.initialize_from_xml(xml)

    law

  end

end
