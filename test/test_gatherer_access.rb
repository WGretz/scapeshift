require 'helper'

class TestGathererAccess < Test::Unit::TestCase
  context "The GathererAccess utility class" do
    should "respond to instance" do
      assert_respond_to Scapeshift::GathererAccess, :instance
    end

    context "when getting a card" do
      setup do
        VCR.use_cassette 'single/Akroma, Angel of Wrath' do
          @card = Scapeshift::GathererAccess.instance.card '193871'
        end
      end

      should "return a Net::HTTPResponse object" do
        assert_kind_of Net::HTTPResponse, @card
      end

      should "return a Net::HTTPOK object" do
        assert_instance_of Net::HTTPOK, @card
      end
    end

    context "when making a search" do
      setup do
        VCR.use_cassette 'cards/Darksteel' do
          @card = Scapeshift::GathererAccess.instance.search :output => 'spoiler', :method => 'text', :set => 'Darksteel'
        end
      end

      should "return a Net::HTTPResponse object" do
        assert_kind_of Net::HTTPResponse, @card
      end

      should "return a Net::HTTPOK object" do
        assert_instance_of Net::HTTPOK, @card
      end
    end

    context "when getting the homepage" do
      setup do
        VCR.use_cassette 'meta' do
          @card = Scapeshift::GathererAccess.instance.homepage
        end
      end

      should "return a Net::HTTPResponse object" do
        assert_kind_of Net::HTTPResponse, @card
      end

      should "return a Net::HTTPOK object" do
        assert_instance_of Net::HTTPOK, @card
      end
    end
  end
end
