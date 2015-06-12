# Cleans up nil attributes before XML export
#
module XMLExportModule
  def self.included(base)
    self.const_set(:XML_INCLUDE, []) unless self.const_defined?(:XML_INCLUDE)
    self.const_set(:XML_EXCLUDE, []) unless self.const_defined?(:XML_EXCLUDE)
  end

  # spoof in blank strings for nil strings, false for nil Booleans
  # (also zeroes out nil-valued *_id fields)
  # include methods and exclude attributes as set by class constants
  def to_xml(options = {})
    self.attributes.each do |k, v|
      if v.nil?
        self.send((k.to_s + "=").to_sym, "")
        self.send((k.to_s + "=").to_sym, false) if self.send(k).nil?
      end
    end
    options[:methods] ||= []
    options[:methods] += self.class.const_get(:XML_INCLUDE)
    options[:except] ||= []
    options[:except] += self.class.const_get(:XML_EXCLUDE)
    super(options)
  end

end
