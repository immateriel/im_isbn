require 'nokogiri'

class InvalidISBNLength < StandardError
end

class InvalidISBNFormat < StandardError
end

class NilISBN < StandardError
end

class CannotConvertToISBN10 < StandardError
end

class InvalidISBNControlKey < StandardError
end

class ISBNInternationalData
  # Convert EAN10 to ISBN10
  # @return [Array<String>]
  def self.convert_ean10(ean)
    ean13 = "978#{ean}"
    isbn = self.find_rec(self.tree, ean13[0..11], [])
    last_suffix = ean13[0..11].gsub(/#{isbn.join("")}/, "")
    isbn << last_suffix
    isbn << ean13[12..12]
    isbn.drop(1)
  end

  # Convert EAN13 to ISBN13
  # @return [Array<String>]
  def self.convert_ean13(ean)
    isbn = self.find_rec(self.tree, ean[0..11], [])
    last_suffix = ean[0..11].gsub(/#{isbn.join("")}/, "")
    isbn << last_suffix
    isbn << ean[12..12]
    isbn
  end

  private

  def self.data_xml
    @@isbn_international_data ||= Nokogiri::XML.parse(File.open(File.join(File.dirname(__FILE__), "../data/RangeMessage.xml")))
  end

  def self.tree
    @@isbn_international_data ||= self.init_tree
  end

  # @return [Array<String>]
  def self.find_rec(branch, ean, ean_arr)
    branch.each do |s|
      prefix = ean[0..s[:length] - 1]
      suffix = ean[s[:length]..ean.length - 1]
      if prefix.to_i >= s[:start_range] && prefix.to_i <= s[:end_range]
        ean_arr << prefix
        self.find_rec(s[:includes], suffix, ean_arr)
        return ean_arr
      end
    end
    []
  end

  def self.init_tree
    tree = [{ length: 3, start_range: 978, end_range: 979, includes: [] }]

    self.data_xml.search("//EAN.UCC").each do |group|
      prefix = group.at("./Prefix").text.split("-")

      group.search("./Rules/Rule").each do |rule|
        range = rule.at("./Range").text.split("-")
        length = rule.at("./Length").text.to_i

        start_range = range[0][0..length - 1].to_i
        end_range = range[1][0..length - 1].to_i

        tree[0][:includes] << { length: length, start_range: start_range, end_range: end_range, includes: [] }
      end
    end

    self.data_xml.search("//Group").each do |group|
      prefix = group.at("./Prefix").text.split("-")
      group.search("./Rules/Rule").each do |rule|
        range = rule.at("./Range").text.split("-")
        length = rule.at("./Length").text.to_i
        start_range = range[0][0..length - 1].to_i
        end_range = range[1][0..length - 1].to_i

        tree[0][:includes].each do |s|
          if s[:length] == prefix[1].length && prefix[1].to_i >= s[:start_range] && prefix[1].to_i <= s[:end_range]
            s[:includes] << { length: length, start_range: start_range, end_range: end_range, includes: [] }
          end
        end
      end
    end
    tree
  end
end

class ISBN
  # Instantiate from any string, raise error if invalid
  # accept ISBN 10, EAN 10, ISBN 13, EAN 13 with key
  # or without control key if exact is false
  # @param [String, Integer, nil] any
  # @param [Boolean] exact
  def initialize(any, exact = false)
    if any
      @ean = any.to_s.delete('-').delete(' ')
      case @ean.length
      when 9
        if exact
          raise InvalidISBNLength, "given ISBN length is #{@ean.length}, must be 10 or 13"
        else
          @type = :ean10
          raise InvalidISBNFormat unless self.class.ean10_check_format(@ean + "0")
          calculated_control = self.class.ean10_control("978" + @ean)
          @ean = @ean + calculated_control
        end
      when 10
        @type = :ean10
        raise InvalidISBNFormat unless self.class.ean10_check_format(@ean)
        given_control = @ean[9..9]
        calculated_control = self.class.ean10_control("978" + @ean)
        raise InvalidISBNControlKey, "given ISBN control key is #{given_control}, must be #{calculated_control}" if given_control != calculated_control
      when 12
        if exact
          raise InvalidISBNLength, "given ISBN length is #{@ean.length}, must be 10 or 13"
        else
          @type = :ean13
          raise InvalidISBNFormat unless self.class.ean13_check_format(@ean + "0")
          calculated_control = self.class.ean13_control(@ean)
          @ean = @ean + calculated_control
        end
      when 13
        @type = :ean13
        raise InvalidISBNFormat unless self.class.ean13_check_format(@ean)
        given_control = @ean[12..12]
        calculated_control = self.class.ean13_control(@ean)
        raise InvalidISBNControlKey, "given ISBN control key is #{given_control}, must be #{calculated_control}" if given_control != calculated_control
      else
        raise InvalidISBNLength, "given ISBN length is #{@ean.length}, must be 10 or 13"
      end
    else
      raise NilISBN
    end
  end

  # Is object an ISBN ? Return false if other type of EAN
  # @return [Boolean]
  def is_isbn?
    case @type
    when :ean13
      prefix = @ean[0..2]
      ["978", "979"].include?(prefix)
    when :ean10
      true
    end
  end

  # Default string
  # @return [String]
  def to_s
    self.to_ean13_s
  end

  # Convert object to EAN 13 string
  # @return [String]
  def to_ean13_s
    case @type
    when :ean13
      @ean
    when :ean10
      self.class.ean13(@ean)
    end
  end

  # Convert object to ISBN 13 array
  # @return [Array<String>]
  def to_isbn13_a
    ISBNInternationalData.convert_ean13(self.to_ean13_s)
  end

  # Convert object to ISBN 13 string
  # @return [String]
  def to_isbn13_s
    self.to_isbn13_a.join("-")
  end

  # Convert object to ISBN 10 array
  # @return [Array<String>]
  def to_isbn10_a
    ISBNInternationalData.convert_ean10(self.to_ean10_s)
  end

  # Convert object to ISBN 10 string
  # @return [String]
  def to_isbn10_s
    self.to_isbn10_a.join("-")
  end

  # Convert object to EAN 10 string
  # @return [String]
  def to_ean10_s
    case @type
    when :ean13
      if @ean.start_with?("978")
        self.class.ean10(@ean)
      else
        raise CannotConvertToISBN10, "given prefix is #{@ean[0..2]}, only 978 can be converted"
      end
    when :ean10
      @ean
    end
  end

  # Check if string can be corrected
  # @return [Boolean]
  def self.correctable?(ean)
    begin
      self.corrected(ean)
      true
    rescue
      false
    end
  end

  # Instantiate from any string, correct if invalid
  # @return [ISBN]
  def self.corrected(ean)
    raise NilISBN if ean.nil?

    ISBN.new(ean[0..-2])
  end

  # Check if string can be instantiated
  # @return [Boolean]
  def self.valid?(ean)
    begin
      self.new(ean)
      true
    rescue
      false
    end
  end

  # Control key for EAN 10
  # @return [String]
  def self.ean10_control(isbn)
    controls = 0
    c = 0
    nisbn = isbn[3..12].split(//)
    for factor in 2..10
      pr = nisbn[c].to_i * (12 - factor)
      controls = controls + pr
      c = c + 1
    end
    r = 11 - controls.modulo(11)

    if r < 10
      r.to_s
    elsif r == 11
      0.to_s
    else
      "X"
    end
  end

  # Control key for EAN 13
  # @return [String]
  def self.ean13_control(isbn)
    nisbn = (isbn).split(//)
    controls = 0
    factor = 3
    for c in 0..11
      controls = controls + nisbn[(11 - c)].to_i * (factor)
      factor = 4 - factor
    end
    (1000 - controls).modulo(10).to_s
  end

  # convert EAN 13 string to EAN 10 string
  # @return [String]
  def self.ean10(isbn)
    (isbn)[3..11] + self.ean10_control(isbn)
  end

  # convert EAN 10 string to EAN 13 string
  # @return [String]
  def self.ean13(isbn)
    "978" + (isbn)[0..8] + self.ean13_control("978" + isbn)
  end

  # check EAN 13 string format
  # @return [Boolean]
  def self.ean13_check_format(ean)
    ean.match?(/^\d{13}$/)
  end

  # check EAN 10 string format
  # @return [Boolean]
  def self.ean10_check_format(ean)
    ean.match?(/^\d{9}(\d|X)$/)
  end

end
