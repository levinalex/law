module Law
  module Treeish
    def children
      @children ||= []
    end
    def append(n)
      if children.empty? || children.last.depth >= n.depth
        children << n
      else
        children.last.append(n)
      end
    end

    def ascii_tree
      subtree = children.map do |c|
        c.ascii_tree.lines.map { |l| "   " + l.rstrip }.join("\n")
      end

      ["`- " + inspect + " (#{depth})", *subtree].join("\n")
    end
  end

  class Section
    include Treeish
    attr_reader :depth

    def initialize(xml)
      @sn = xml.xpath("string(./metadaten/gliederungseinheit/gliederungskennzahl)")
      @bez = xml.xpath("string(./metadaten/gliederungseinheit/gliederungsbez)")
      @title = xml.xpath("string(./metadaten/gliederungseinheit/gliederungstitel)")
      @title = @title.gsub(/\s+/, " ")

      @depth = @sn.length / 3
      @sections = []
    end

    def inspect
      "S: #{@bez} #{@sn}"
    end
  end

  class Para
    def depth
      Float::INFINITY
    end

    def initialize(xml)
      @bez = xml.xpath(%Q(string(./metadaten/enbez)))
      @title = xml.xpath("string(./metadaten/titel)")
    end

    def inspect
      [@bez, @title.gsub(/\s+/, " ").strip].join(" - ")
    end

    def ascii_tree
      inspect
    end
  end

  class Law
    include Treeish

    attr_accessor :uid
    attr_accessor :short_name
    attr_accessor :title

    def short_name=(val)
      @short_name = val.empty? ? nil : val
    end

    def depth
      0
    end

    def inspect
      "LAW: " + [@uid, @short_name].compact.join(" - ")
    end

    def add_section(section)
      append(section)
    end

    def add_para(para)
      append(para)
    end

    def initialize(xml)
      @children = []

      doc_meta = xml.at_xpath(%Q(dokumente/norm[/dokumente/@doknr=@doknr]/metadaten))

      self.uid = doc_meta.at_xpath(%Q(./jurabk)).text
      self.short_name = doc_meta.xpath(%Q(string(./kurzue)))

      xml.xpath(%Q(dokumente/norm[/dokumente/@doknr!=@doknr])).each do |norm|
        if norm.at_xpath(%Q(./metadaten/gliederungseinheit))
          self.add_section(Section.new(norm))
        elsif norm.at_xpath("./metadaten/enbez")
          self.add_para(Para.new(norm))
        else
          raise "unexpected thing in XML"
        end
      end
    end
  end
end
