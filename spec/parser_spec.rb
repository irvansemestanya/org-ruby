
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Orgmode::Parser do
  it "should open ORG files" do
    parser = Orgmode::Parser.load(RememberFile)
  end

  it "should fail on non-existant files" do
    lambda { parser = Orgmode::Parser.load("does-not-exist.org") }.should raise_error
  end

  it "should load all of the lines" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.lines.length.should eql(53)
  end

  it "should find all headlines" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.should have(12).headlines
  end

  it "can find a headline by index" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.headlines[1].line.should eql("** YAML header in Webby\n")
  end

  it "should determine headline levels" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.headlines[0].level.should eql(1)
    parser.headlines[1].level.should eql(2)
  end

  it "should put body lines in headlines" do
    parser = Orgmode::Parser.load(RememberFile)
    parser.headlines[0].should have(0).body_lines
    parser.headlines[1].should have(6).body_lines
  end

  it "should understand lines before the first headline" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.should have(19).header_lines
  end

  it "should load in-buffer settings" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.should have(12).in_buffer_settings
    parser.in_buffer_settings["TITLE"].should eql("Freeform")
    parser.in_buffer_settings["EMAIL"].should eql("bdewey@gmail.com")
    parser.in_buffer_settings["LANGUAGE"].should eql("en")
  end

  it "should understand OPTIONS" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.should have(19).options
    parser.options["TeX"].should eql("t")
    parser.options["todo"].should eql("t")
    parser.options["\\n"].should eql("nil")
    parser.export_todo?.should be_true
    parser.options.delete("todo")
    parser.export_todo?.should be_false
  end

  it "computes outline level numbering" do
    parser = Orgmode::Parser.new ""
    parser.get_next_headline_number(1).should eql("1")
    parser.get_next_headline_number(1).should eql("2")
    parser.get_next_headline_number(1).should eql("3")
    parser.get_next_headline_number(1).should eql("4")
    parser.get_next_headline_number(2).should eql("4.1")
    parser.get_next_headline_number(2).should eql("4.2")
    parser.get_next_headline_number(1).should eql("5")
    parser.get_next_headline_number(2).should eql("5.1")
    parser.get_next_headline_number(2).should eql("5.2")
    parser.get_next_headline_number(4).should eql("5.2.0.1")
  end

  it "should skip in-buffer settings inside EXAMPLE blocks" do
    parser = Orgmode::Parser.load(FreeformExampleFile)
    parser.should have(0).in_buffer_settings
  end

  it "should return a textile string" do
    parser = Orgmode::Parser.load(FreeformFile)
    parser.to_textile.should be_kind_of(String)
  end

  it "can translate textile files" do
    data_directory = File.join(File.dirname(__FILE__), "textile_examples")
    org_files = File.expand_path(File.join(data_directory, "*.org" ))
    files = Dir.glob(org_files)
    files.each do |file|
      basename = File.basename(file, ".org")
      textile_name = File.join(data_directory, basename + ".textile")
      textile_name = File.expand_path(textile_name)

      expected = IO.read(textile_name)
      expected.should be_kind_of(String)
      parser = Orgmode::Parser.new(IO.read(file))
      actual = parser.to_textile
      actual.should be_kind_of(String)
      actual.should == expected
    end
  end

  it "can translate to html" do
    data_directory = File.join(File.dirname(__FILE__), "html_examples")
    org_files = File.expand_path(File.join(data_directory, "*.org" ))
    files = Dir.glob(org_files)
    files.each do |file|
      basename = File.basename(file, ".org")
      textile_name = File.join(data_directory, basename + ".html")
      textile_name = File.expand_path(textile_name)

      expected = IO.read(textile_name)
      expected.should be_kind_of(String)
      parser = Orgmode::Parser.new(IO.read(file))
      actual = parser.to_html
      actual.should be_kind_of(String)
      actual.should == expected
    end
  end
end

