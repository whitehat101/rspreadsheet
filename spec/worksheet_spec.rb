require 'spec_helper'
using ClassExtensions if RUBY_VERSION > '2.1'

describe Rspreadsheet::Worksheet do
  describe "from test workbook file" do 
    before do 
      @sheet = Rspreadsheet.new($test_filename).worksheets(1)
    end
    it 'contains nonempty xml in rows for testfile' do
      @sheet.rows(1).xmlnode.elements.size.should be >1
    end
    it 'uses detach_my_subnode_respect_repeated well' do
      @sheet.detach_my_subnode_respect_repeated(50, {:xml_items_node_name => 'table-row', :xml_repeated_attribute => 'number-rows-repeated'})
      @sheet.rows(50).detach_my_subnode_respect_repeated(12, {:xml_items_node_name => 'table-cell', :xml_repeated_attribute => 'number-columns-repeated'})
    end
  end
end

describe Rspreadsheet::Worksheet do
  describe "newly created" do 
    before do
      @book = Rspreadsheet.new
      @sheet = @book.create_worksheet
    end
    it 'has correctly namespaced xmlnode' do
      @xmlnode = @sheet.xmlnode
      @xmlnode.namespaces.to_a.size.should >5
      @xmlnode.namespaces.find_by_prefix('office').should_not be_nil
      @xmlnode.namespaces.find_by_prefix('table').should_not be_nil
      @xmlnode.namespaces.namespace.should_not be_nil
      @xmlnode.namespaces.namespace.prefix.should == 'table'
    end
    it 'has correct name' do
      @sheet2 = @book.create_worksheet('test')
      @sheet2.name.should eq 'test'
      @sheet3 = @book.create_worksheet
      @sheet3.name.should eq 'Sheet3'
    end
    it 'remembers the value stored to A1 cell' do
      @sheet[1,1].should == nil
      @sheet[1,1] = 'test text'
      @sheet[1,1].class.should == String
      @sheet[1,1].should == 'test text'
    end
    it 'value stored to A1 is accesible using different syntax' do
      @sheet[2,2] = 'test text'
      @sheet[2,2].should == 'test text'
      @sheet.B2.should == 'test text'
      @sheet['B2'].should == 'test text'
      @sheet['2','2'].should == 'test text'
      @sheet['2','B'].should == 'test text'
      @sheet[2,'B'].should == 'test text'
      @sheet['B',2].should == 'test text'
      @sheet['B','2'].should == 'test text'
      
      @sheet.cells(2,2).value.should == 'test text'
      @sheet.cells('B2').value.should == 'test text'
      @sheet.cells('B','2').value.should == 'test text'
      @sheet.cells(2,'B').value.should == 'test text'
    end
    it 'makes Cell object accessible' do
      @sheet.cells(1,1).value = 'test text'
      @sheet.cells(1,1).class.should == Rspreadsheet::Cell
    end
    it 'has name, which can be changed and is remembered' do
      @sheet.name.should_not be(nil) # it should have some default name
      @sheet.name = 'Icecream'
      @sheet.name.should == 'Icecream'
      @sheet.name = 'Cofee'
      @sheet.name.should == 'Cofee'    
    end
    it 'out of range indexes return nil value or raise if configured to do so' do
      @sheet[999,999].should == nil

      pom = Rspreadsheet.raise_on_negative_coordinates
      expect { @sheet[-1,-1] }.to raise_error   # default is to raise error
      expect { @sheet[0,0] }.to raise_error
      expect { @sheet[-2,-5] }.to raise_error
      
      Rspreadsheet.raise_on_negative_coordinates = false
      @sheet[-1,-1].should be_nil               # return nil if configured to do so
      @sheet[0,0].should be_nil
      @sheet[-2,-5].should be_nil
      
      Rspreadsheet.raise_on_negative_coordinates = pom  # reset the setting back
    end
    it 'returns nil with negative index or raise if configured to do so' do
      pom = Rspreadsheet.raise_on_negative_coordinates
      expect { @sheet.rows(-1) }.to raise_error          # default is to raise error
      
      Rspreadsheet.raise_on_negative_coordinates = false
      @sheet.rows(-1).should == nil                      # return nil if configured to do so
      Rspreadsheet.raise_on_negative_coordinates = pom   # reset the setting back
    end
  end
end
