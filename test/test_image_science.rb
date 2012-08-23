dir = File.expand_path "~/.ruby_inline"
if test ?d, dir then
  require 'fileutils'
  puts "nuking #{dir}"
  # force removal, Windoze is bitching at me, something to hunt later...
  FileUtils.rm_r dir, :force => true
end

require 'rubygems'
require 'minitest/unit'
require 'minitest/autorun' if $0 == __FILE__
require 'image_science'

class TestImageScience < MiniTest::Unit::TestCase
  def setup
    @path = 'test/pix.png'
    @tmppath = 'test/pix-tmp.png'
    @h = @w = 50
  end

  def teardown
    File.unlink @tmppath if File.exist? @tmppath
  end

  def test_class_with_image
    ImageScience.with_image @path do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
      assert img.save(@tmppath)
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
    end
  end

  def test_class_with_image_missing
    assert_raises TypeError do
      ImageScience.with_image @path + "nope" do |img|
        flunk
      end
    end
  end

  def test_class_with_image_missing_with_img_extension
    assert_raises TypeError do
      assert_nil ImageScience.with_image("nope#{@path}") do |img|
        flunk
      end
    end
  end

  def test_class_with_image_from_memory
    data = File.new(@path).binmode.read

    ImageScience.with_image_from_memory data do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
      assert img.save(@tmppath)
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
    end
  end

  def test_class_with_image_from_memory_empty_string
    assert_raises TypeError do
      ImageScience.with_image_from_memory "" do |img|
        flunk
      end
    end
  end

  def test_bytes
    data = File.new(@path).binmode.read

    ImageScience.with_image_from_memory data do |img|
      File.open(@tmppath, "wb"){|f| f.write img.bytes}
      assert File.size(@tmppath) > 1100

      ImageScience.with_image(@tmppath) do |img2|
        assert_equal(img2.width, img.width)
        assert_equal(img2.height, img.height)
      end
    end
  end

  def test_bytes_with_type
    data = File.new(@path).binmode.read
    @tmppath = "test/pix-tmp.jpg"

    ImageScience.with_image_from_memory data do |img|
      File.open(@tmppath, "wb"){|f| f.write img.bytes("jpeg")}
      assert_equal 1256, File.size(@tmppath)
      
      ImageScience.with_image(@tmppath) do |img2|
        assert_equal(img2.width, img.width)
        assert_equal(img2.height, img.height)
      end
    end
  end

  def test_resize
    ImageScience.with_image @path do |img|
      img.resize(25, 25) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_floats
    ImageScience.with_image @path do |img|
      img.resize(25.2, 25.7) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_zero
    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(0, 25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    refute File.exists?(@tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(25, 0) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    refute File.exists?(@tmppath)
  end

  def test_resize_negative
    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(-25, 25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    refute File.exists?(@tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(25, -25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    refute File.exists?(@tmppath)
  end

  def test_thumbnail
    ImageScience.with_image @path do |img|
      img.thumbnail(29) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 29, img.height
      assert_equal 29, img.width
    end
  end

end
