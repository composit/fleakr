require File.dirname(__FILE__) + '/../test_helper'

module Fleakr
  class UserTest < Test::Unit::TestCase

    should_have_many :photos, :groups, :sets

    describe "The User class" do

      should_find_one :user, :by => :username, :call => 'people.findByUsername', :path => 'rsp/user'
      should_find_one :user, :by => :email, :with => :find_email, :call => 'people.findByEmail', :path => 'rsp/user'

    end

    describe "An instance of User" do
      context "when populating the object from an XML document" do
        before do
          @object = User.new(Hpricot.XML(read_fixture('people.findByUsername')))
          @object.populate_from(Hpricot.XML(read_fixture('people.getInfo')))
        end

        should_have_a_value_for :id           => '31066442@N69'
        should_have_a_value_for :username     => 'frootpantz'
        should_have_a_value_for :photos_url   => 'http://www.flickr.com/photos/frootpantz/'
        should_have_a_value_for :profile_url  => 'http://www.flickr.com/people/frootpantz/'
        should_have_a_value_for :photos_count => '3907'
        should_have_a_value_for :icon_server  => '30'
        should_have_a_value_for :icon_farm    => '1'
      end

      context "in general" do

        before { @user = User.new }

        it "should be able to retrieve additional information about the current user" do
          response = mock_request_cycle :for => 'people.getInfo', :with => {:user_id => @user.id}
          @user.expects(:populate_from).with(response.body)

          @user.load_info
        end

        it "should be able to generate an icon URL when the :icon_server value is greater than zero" do
          @user.stubs(:icon_server).with().returns('1')
          @user.stubs(:icon_farm).with().returns('2')
          @user.stubs(:id).with().returns('45')

          @user.icon_url.should == 'http://farm2.static.flickr.com/1/buddyicons/45.jpg'
        end

        it "should return the default icon URL when the :icon_server value is zero" do
          @user.stubs(:icon_server).with().returns('0')
          @user.icon_url.should == 'http://www.flickr.com/images/buddyicon.jpg'
        end

        it "should return the default icon URL when the :icon_server value is nil" do
          @user.stubs(:icon_server).with().returns(nil)
          @user.icon_url.should == 'http://www.flickr.com/images/buddyicon.jpg'
        end
      end
    end

  end
end