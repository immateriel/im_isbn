require 'simplecov'
SimpleCov.start

require 'im_isbn'
require 'minitest/autorun'
require 'shoulda'

class TestIsbn < Minitest::Test
  context "initializer" do
    setup do
      @expected_isbn = "9782814507159"
    end

    should "match original" do
      assert_equal @expected_isbn, ISBN.new("9782814507159").to_s
    end

    should "match ISBN13" do
      assert_equal @expected_isbn, ISBN.new("978-2-8145-0715-9").to_s
    end

    should "add EAN13 control" do
      assert_equal @expected_isbn, ISBN.new("978281450715").to_s
    end

    should "convert ISBN10 to EAN13" do
      assert_equal @expected_isbn, ISBN.new("281450715X").to_s
    end

    should "add EAN10 control" do
      assert_equal @expected_isbn, ISBN.new("281450715").to_s
      assert_equal "281450715X", ISBN.new("281450715").to_ean10_s
      assert_equal "2765410054", ISBN.new("2-7654-1005").to_ean10_s
      assert_equal "2811210830", ISBN.new("281121083").to_ean10_s
    end

    should "accept integer" do
      assert_equal @expected_isbn, ISBN.new(9782814507159).to_s
    end

    should "raise an error if nil" do
      assert_raises NilISBN do
        ISBN.new(nil)
      end
      assert_raises NilISBN do
        ISBN.corrected(nil)
      end
    end

    should "raise an error if invalid control" do
      assert_raises InvalidISBNControlKey do
        ISBN.new("9782814507151")
      end

      assert_raises InvalidISBNControlKey do
        ISBN.new("2814507150")
      end
    end

    should "raise an error if invalid format" do
      assert_raises InvalidISBNFormat do
        ISBN.new("9782814507AAA")
      end

      assert_raises InvalidISBNFormat do
        ISBN.new("9782814507AA")
      end

      assert_raises InvalidISBNFormat do
        ISBN.new("2814507ABX")
      end

      assert_raises InvalidISBNFormat do
        ISBN.new("2814507AB")
      end
    end

    should "raise an error if more than 13 characters" do
      assert_raises InvalidISBNLength do
        ISBN.new("97828145071534")
      end
    end

    should "raise an error if exact required" do
      assert_raises InvalidISBNLength do
        ISBN.new("978281450715", true)
      end

      assert_raises InvalidISBNLength do
        ISBN.new("281450715", true)
      end
    end
  end

  context "correction" do
    should "be correctable" do
      assert ISBN.correctable?("9782814507151")
    end

    should "not be correctable" do
      refute ISBN.correctable?("97828145071")
    end

    should "correct invalid control" do
      assert_equal "9782814507159", ISBN.corrected("9782814507151").to_s
    end

    should "correct invalid EAN10 control" do
      assert_equal "281450715X", ISBN.corrected("2814507150").to_ean10_s
    end

    should "correct ISBN13" do
      assert_equal "9782814507159", ISBN.corrected("978-2-8145-0715-9").to_s
      assert_equal "281450715X", ISBN.corrected("2-8145-0715-X").to_ean10_s
      assert_equal "9782382112939", ISBN.corrected("978-2-38211-293-9       ").to_s
      assert_equal "9782382112939", ISBN.corrected("978-2- 38211-293-9 ").to_s
    end
  end

  context "validity" do
    should "be valid" do
      assert ISBN.valid?("9782814507159")
    end

    should "be invalid" do
      refute ISBN.valid?("9782814507151")
    end

    should "be an ISBN" do
      assert ISBN.new("9782814507159").is_isbn?
      assert ISBN.new("281450715X").is_isbn?
    end

    should "not be an ISBN" do
      refute ISBN.new("3612226273211").is_isbn?
    end
  end

  context "conversion" do
    should "convert to ISBN13 string" do
      assert_equal "978-2-8145-0715-9", ISBN.new("9782814507159").to_isbn13_s
    end

    should "convert to ISBN13 array" do
      assert_equal %w[978 2 8145 0715 9], ISBN.new("9782814507159").to_isbn13_a
    end

    should "convert to EAN10" do
      assert_equal "281450715X", ISBN.new("9782814507159").to_ean10_s
      assert_equal "281450715X", ISBN.new("281450715X").to_ean10_s
    end

    should "convert to ISBN10 string" do
      assert_equal "2-8145-0715-X", ISBN.new("9782814507159").to_isbn10_s
    end

    should "convert to ISBN10 array" do
      assert_equal %w[2 8145 0715 X], ISBN.new("9782814507159").to_isbn10_a
    end

    should "fail to convert 979 to ISBN10 string" do
      assert_raises CannotConvertToISBN10 do
        ISBN.new("9791030001006").to_isbn10_s
      end
    end

  end
end
