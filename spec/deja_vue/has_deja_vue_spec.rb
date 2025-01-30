require 'spec_helper'

describe DejaVue::InstanceMethods do
  before(:each) do
    clear_dbs
	  @supplier = Supplier.new(:name => 'a supplier')
		@product = Product.new(:title => 'The Product', :description => 'The Product is the new kid on the block', :dimensions => '12x12')
	end
	describe "version_changes" do
		describe "after save" do
			before(:each) do
				@supplier.save
				@product.save
			end
			it "should keep track changed fields" do
				@product.version_changes.should == ["dimensions", "title", "description"]
				@supplier.version_changes.should == ['name']
			end
			it "should keep track on update to" do	
				@product.title = "TTT Prod"
				@product.save!
				@product.version_changes.should == ["title"]
			end
		end
		describe "before save" do
			it "should be nil" do
				@product.version_changes.should be_nil
				@supplier.version_changes.should be_nil
			end
		end
	end
	describe "versionate_as" do
		it "should versionate objetc creation" do
			@product.save!
			@product.histories(:kind_of_version => 'create').size.should == 1
			@supplier.save!
			@supplier.histories(:kind_of_version => 'create').size.should == 1
		end
		it "should versionate object update" do
			@product.save!
			@product.title = "TTTPROD"
			@product.save!
			@product.histories.size.should == 2
			@product.histories(:kind_of_version => 'update').size.should == 1
			@supplier.save!
			@supplier.name = "ahahahah"
  		@supplier.save!		
			@supplier.histories(:kind_of_version => 'update').size.should == 1
		end
		it "should versionate object destruction" do
			@product.save!
			@product.destroy
			@product.histories.size.should == 2
			@product.histories(:kind_of_version => 'destroy').size.should == 1
			@supplier.save!
			@supplier.destroy
			@supplier.histories(:kind_of_version => 'destroy').size.should == 1	
		end
	end
	describe "histories(extra_options={})" do
		it "should return an empty array for new record" do
			@product.should be_new_record
			@product.histories.should be_empty
			@supplier.should be_new_record
			@supplier.histories.should be_empty
		end
		it "should store all changes" do
			@product.histories.size.should == 0
			@product.save!
			@product.histories.size.should == 1
			@product.title = "TTT Prod"
			@product.save!
			@product.histories.size.should == 2
		end
		it "should not let class or id to be changed" do
			@product.save!
			@product.histories(:versionable_type => 'Test').size.should == 1
			@product.histories(:versionable_type => 'Test')[0].versionable_type.should == 'Product'
			@product.histories(:versionable_id => 'blablabla')[0].versionable_id.should == @product.id.to_s
		end
	end
	describe ".history(id)" do
		it "should raise an error for non bson object" do
			@product.save!
			lambda{
				@product.history('blablabla')
			}.should raise_error(BSON::InvalidObjectId)
		end
		it "should return nil for a non existent id" do
			@product.save!
			@product.history(BSON::ObjectId.new).should be_nil
		end
		
		it "should return a History for an existent id" do
			@product.save!
			@history = @product.histories.first
			@product.history(@history.id).should == @history
		end
	end
end
