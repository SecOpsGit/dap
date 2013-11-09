module Dap
module Filter

class FilterRename
  include Base
  def process(doc)
    self.opts.each_pair do |k,v|
      if doc.has_key?(k)
        doc[v] = doc[k]
        doc.delete(k)
      end
    end
   [ doc ]
  end
end

class FilterRemove
  include Base
  def process(doc)
    self.opts.each_pair do |k,v|
      if doc.has_key?(k)
        doc.delete(k)
      end
    end
   [ doc ]
  end
end

class FilterSelect
  include Base
  def process(doc)
    ndoc = {}
    self.opts.each_pair do |k,v|
      if doc.has_key?(k)
        ndoc[k] = doc[k]
      end
    end
   [ ndoc ]
  end
end

class FilterInsert
  include Base
  def process(doc)
    self.opts.each_pair do |k,v|
        doc[k] = v
    end
   [ doc ]
  end
end

class FilterSmatch
  include Base
  def process(doc)
    self.opts.each_pair do |k,v|
      if doc.has_key?(k) and doc[k].to_s.index(v)
        return [ doc ]
      end
    end
    [ ]
  end
end

class FilterSavoid
  include Base
  def process(doc)
    self.opts.each_pair do |k,v|
      if doc.has_key?(k) and doc[k].to_s.index(v)
        return [ ]
      end
    end
    [ doc ]
  end
end

class FilterTransform
  include Base
  def process(doc)
    self.opts.each_pair do |k,v|
      if doc.has_key?(k)
        case v
        when 'downcase'
          doc[k] = doc[k].to_s.downcase
        when 'upcase'
          doc[k] = doc[k].to_s.upcase
        when 'ascii'
          doc[k] = doc[k].to_s.gsub(/[\x00-\x1f\x7f-\xff]/n, '')
        when 'utf8encode'
          doc[k] = doc[k].to_s.encode!('UTF-8', invalid: :replace, undef: :replace, replace: '')
        when 'base64decode'
          doc[k] = doc[k].to_s.unpack('m*').first        
        when 'base64encode'
          doc[k] = [doc[k].to_s].pack('m*').gsub(/\s+/n, '')
        when 'qprintdecode'
          doc[k] = doc[k].to_s.gsub(/=([0-9A-Fa-f]{2})/n){ |x| [x[1,2]].pack("H*") }
        when 'qprintencode'
          doc[k] = doc[k].to_s.gsub(/[\x00-\x20\x3d\x7f-\xff]/n){|x| ( "=%.2x" % x.unpack("C").first ).upcase }
        when 'hexdecode'
          doc[k] = [ doc[k].to_s ].pack("H*")
        when 'hexencode'
          doc[k] = doc[k].to_s.unpack("H*").first      
        end
      end
    end
   [ doc ]
  end
end

class FilterLimitLen
  include Base
  def process(doc)
    self.opts.each_pair do |k,v|
      if doc.has_key?(k)
        doc[k] = doc[k].to_s[0, v.to_i]
      end
    end
   [ doc ]
  end
end

class FilterLineSplit
  include Base
  def process(doc)
    lines = [ ]
    self.opts.each_pair do |k,v|
      if doc.has_key?(k)
        doc[k].to_s.split(/\n/).each do |line|
          lines << doc.merge({ "#{k}.line" => line })
        end
      end
    end
   [ lines ]
  end  
end

class FilterWordSplit
  include Base
  def process(doc)
    lines = [ ]
    self.opts.each_pair do |k,v|
      if doc.has_key?(k)
        doc[k].to_s.split(/\W/).each do |line|
          lines << doc.merge({ "#{k}.word" => line })
        end
      end
    end
   [ lines ]
  end  
end

class FilterTrace
  include Base
  def process(doc)
    $stderr.puts "TRACE: #{Time.now.to_s} #{doc.inspect}"
    [ doc ]
  end
end

end
end
