require 'spec_helper'
using ClassExtensions if RUBY_VERSION > '2.1'

describe Rspreadsheet do
  it 'can open spreadsheet and save it to file, resulting file has same content as original' do
    spreadsheet = Rspreadsheet.new($test_filename)                 # open a file
    
    # save it to temp file
    tmp_filename = '/tmp/testfile1.ods'        
    File.delete(tmp_filename) if File.exists?(tmp_filename)  # first delete temp file
    spreadsheet.save(tmp_filename)                                  # and save spreadsheet as temp file
    
    # now compare content saved file to original
    contents_of_files_are_identical?($test_filename,tmp_filename).should == true
  end
  
  it 'can open spreadsheet and store it to IO object', :pending => 'Under development' do
    spreadsheet = Rspreadsheet.new($test_filename)                 # open a file
    
    stringio = StringIO.new
    spreadsheet.save(stringio)
    
    stringio.size.should > 30000
    
    # save it to temp file
    tmp_filename = '/tmp/testfile1.ods'        
    File.delete(tmp_filename) if File.exists?(tmp_filename)         # first delete temp file
    # and save stream as temp file
    File.open(tmp_filename, "w") do |f|
      f.write stringio.read                                  
    end
     
    contents_of_files_are_identical?($test_filename,tmp_filename).should == true
  end
end

def contents_of_files_are_identical?(filename1,filename2)
  @content_xml1 = Zip::File.open(filename1) do |zip|
    LibXML::XML::Document.io zip.get_input_stream('content.xml')
  end
  @content_xml2 = Zip::File.open(filename2) do |zip|
    LibXML::XML::Document.io zip.get_input_stream('content.xml')
  end
  return contents_are_identical?(@content_xml1,@content_xml2)
end

def contents_are_identical?(content_xml1,content_xml2)
  content_xml2.root.first_diff(content_xml1.root).should be_nil
  content_xml1.root.first_diff(content_xml2.root).should be_nil
  
  return (content_xml1.root == content_xml2.root)
end
