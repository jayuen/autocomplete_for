require 'test_helper'

class AutocompleteForTest < ActiveSupport::TestCase
  load_schema

  class Vendor < ActiveRecord::Base; end
  class Customer < ActiveRecord::Base; end

  class AutoCompleteForCustomerTestModel < ActiveRecord::Base
    belongs_to :customer

    autocomplete_for :customer, :name, :allow_nil => true do
      self.customer = Customer.find(:first, :conditions => {:name => @customer_name})
    end
    autocomplete_for :customer, :code, :allow_nil => true do
      self.customer = Customer.find(:first, :conditions => {:code => @customer_code})
    end
  end

  class AutoCompleteForVendorTestModel < ActiveRecord::Base
    belongs_to :vendor

    autocomplete_for :vendor, :name do
      self.vendor = Vendor.find(:first, :conditions => {:name => @vendor_name})
    end
    autocomplete_for :vendor, :code do
      self.vendor = Vendor.find(:first, :conditions => {:code => @vendor_code})
    end
  end

  class AutoCompleteForSuppressIfTestModel < ActiveRecord::Base
    belongs_to :customer
    autocomplete_for :customer, :name, :suppress_if => Proc.new {suppress?} do
      self.customer = Customer.find(:first, :conditions => {:name => @customer_name})
    end

    def suppress?
      true
    end
  end

  def setup
    Vendor.destroy_all
    Customer.destroy_all
    @vendor_nil_code = Vendor.create! :name => "Nil Code"
    @vendor = Vendor.create! :name => "Vendor Name", :code => "Vendor Code"
    @autocomplete_for_vendor = AutoCompleteForVendorTestModel.new

    @customer = Customer.create! :name => "Customer Name", :code => "Customer Code"
    @autocomplete_for_customer = AutoCompleteForCustomerTestModel.new
  end

  test "with valid name" do
    @autocomplete_for_vendor.update_attributes! :vendor_name => @vendor.name 

    assert_equal @vendor, @autocomplete_for_vendor.vendor
  end
  
  test "with invalid name" do
    @autocomplete_for_vendor.update_attributes :vendor_name => "Not a Vendor Name"

    assert_nil @autocomplete_for_vendor.vendor
    assert @autocomplete_for_vendor.errors.on(:vendor_name)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor_code)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor)
  end

  test "with blank name" do
    @autocomplete_for_vendor.update_attributes :vendor_name => ""

    assert_nil @autocomplete_for_vendor.vendor
    assert @autocomplete_for_vendor.errors.on(:vendor_name)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor_code)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor)
  end

  test "with nil name" do
    @autocomplete_for_vendor.update_attributes :vendor_name => nil 

    assert_nil @autocomplete_for_vendor.vendor
    assert @autocomplete_for_vendor.errors.on(:vendor)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor_code)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor_name)
  end

  test "should clear existing association" do
    @autocomplete_for_vendor.update_attributes! :vendor => @vendor
    assert_equal @vendor, @autocomplete_for_vendor.vendor

    @autocomplete_for_vendor.update_attributes :vendor_name => ""
    assert_nil @autocomplete_for_vendor.vendor
    assert @autocomplete_for_vendor.errors.on(:vendor_name)

    assert_nil @autocomplete_for_vendor.errors.on(:vendor_code)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor)
  end

  test "should not clear existing association" do
    @autocomplete_for_vendor.update_attributes! :vendor => @vendor
    assert_equal @vendor, @autocomplete_for_vendor.vendor

    @autocomplete_for_vendor.update_attributes! :vendor_name => nil
    assert_equal @vendor, @autocomplete_for_vendor.vendor
  end

  test "should clear existing association using field that can be nil" do
    @autocomplete_for_vendor.update_attributes! :vendor => @vendor
    assert_equal @vendor, @autocomplete_for_vendor.vendor

    @autocomplete_for_vendor.update_attributes :vendor_code => ""
    assert_nil @autocomplete_for_vendor.vendor
    assert @autocomplete_for_vendor.errors.on(:vendor_code)

    assert_nil @autocomplete_for_vendor.errors.on(:vendor_name)
    assert_nil @autocomplete_for_vendor.errors.on(:vendor)
  end

  test "allow_nil with valid name" do
    @autocomplete_for_customer.update_attributes! :customer_name => @customer.name 

    assert_equal @customer, @autocomplete_for_customer.customer
  end
  
  test "allow_nil with invalid name" do
    @autocomplete_for_customer.update_attributes :customer_name => "Not A Customer Name" 

    assert_nil @autocomplete_for_customer.customer
    assert @autocomplete_for_customer.errors.on(:customer_name)
    assert_nil @autocomplete_for_customer.errors.on(:customer_code)
    assert_nil @autocomplete_for_customer.errors.on(:customer)
  end

  test "allow_nil with blank name" do
    @autocomplete_for_customer.update_attributes! :customer_name => "" 

    assert_nil @autocomplete_for_customer.customer
  end

  test "allow_nil with nil name" do
    @autocomplete_for_customer.update_attributes! :customer_name => nil 

    assert_nil @autocomplete_for_customer.customer
  end

  test "allow_nil should clear existing association" do
    @autocomplete_for_customer.update_attributes! :customer => @customer
    assert_equal @customer, @autocomplete_for_customer.customer

    @autocomplete_for_customer.update_attributes! :customer_name => ""
    assert_nil @autocomplete_for_customer.customer
  end

  test "allow_nil should not clear existing association" do
    @autocomplete_for_customer.update_attributes! :customer => @customer
    assert_equal @customer, @autocomplete_for_customer.customer

    @autocomplete_for_customer.update_attributes! :customer_name => nil
    assert_equal @customer, @autocomplete_for_customer.customer
  end

  test "suppress_if suppress association" do
    suppress_if_model = AutoCompleteForSuppressIfTestModel.new
    suppress_if_model.update_attributes! :customer_name => @customer.name
    assert_equal nil, suppress_if_model.customer
    assert_equal true, suppress_if_model.valid?
  end
end
