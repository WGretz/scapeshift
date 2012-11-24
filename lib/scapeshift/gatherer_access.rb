# encoding: utf-8

require 'singleton'
require 'net/http'
require 'cgi'
require 'uri'

module Scapeshift
  ##
  # Utility class for accessing the Gatherer site. It uses the singleton pattern so it enforces using the same instance
  # which rewards us with a single HTTP connection with Keep-Alive that speeds things up considerably. Also allows for a
  # more centralized handling of the cryptic Gatherer parameters.
  #
  # Note that it will follow redirects as long as there is a redirect response with a Location header.
  #
  # Generally its methods return a Net::HTTPResponse object.
  #
  # @author Eric Cohen
  #
  # @since 1.2.0
  #
  class GathererAccess
    include Singleton

    ##
    # Parameters for Gatherer searching. These can receive arbitrary stings as values that will be searched as-is. Each
    # value that is specified will be used as a whole AND condition (will be interpolated in one +["<search term>"]
    # parameter).
    SEARCH_TEXT_OPTIONS = [ :name, :format, :set ]

    ##
    # All allowed options and parameters for Gatherer searching.
    SEARCH_ALLOWED_OPTIONS = SEARCH_TEXT_OPTIONS + [ :output, :method ]

    ##
    # Requests a card with a given multiverse ID from Gatherer website.
    #
    # @param [String] multiverse_id The multiverse ID to find
    #
    # @return [Net::HTTPResponse] The HTTP response object
    #
    # @author Eric Cohen
    #
    # @since 1.2.0
    #
    def card(multiverse_id)
      get '/Pages/Card/Details.aspx', :multiverseid => multiverse_id
    end

    ##
    # Makes a search for given options on the Gatherer website. Note that if there's a single card match for this search
    # Gatherer will not give a list with one entry, but will redirect to the card details page (and this *will* follow
    # the redirect).
    #
    # The Gatherer results page output available formats are combinations of the :output and :method options:
    #
    # * Standard:       :output => 'standard'
    # * Compact:        :output => 'compact'
    # * Checklist:      :output => 'checklist'
    # * Visual Spoiler: :output => 'spoiler', :method => 'text'
    # * Text Spoiler:   :output => 'spoiler', :method => 'visual'
    #
    # Choosing one is required for the results page to render successfully, however if you expect to have exactly one
    # result and be redirected to it, these will not be needed.
    #
    # @option options [String] :name ('') The card name to search for (eg. "Jace Beleren")
    # @option options [String] :format ('') The format to search for (eg. "Legacy"), block names are accepted here too
    # @option options [String] :set ('') The set to search for (eg. "Darksteel")
    #
    # @option options [String] :output ('') The format output (eg. "spoiler")
    # @option options [String] :method ('') The format method (eg. "text")
    #
    # @return [Net::HTTPResponse] The HTTP response object
    #
    # @author Eric Cohen
    #
    # @since 1.2.0
    #
    def search(options = {})
      params = options.keep_if { |k, v| SEARCH_ALLOWED_OPTIONS.include? k }
      SEARCH_TEXT_OPTIONS.each { |key| params[key] = '+["%s"]' % options[key] unless options[key].nil? }
      get '/Pages/Search/Default.aspx', options
    end

    ##
    # Requests the Gatherer website homepage. Contains lots of meta info like a list of all Formats, Sets
    # and Card Types.
    #
    # @return [Net::HTTPResponse] The HTTP response object
    #
    # @author Eric Cohen
    #
    # @since 1.2.0
    #
    def homepage
      get '/Pages/Default.aspx'
    end

    #########
    protected
    #########

    ##
    # Makes a GET request to the Gatherer website using a shared connection that has Keep-Alive. Also follows redirects
    # as long as there is a redirect response with a Location header.
    #
    # @author Eric Cohen
    #
    # @param [String] path The path to make a request to (eg. "/Pages/Default.aspx")
    # @param [Hash] query The query parameters in a hash (eg. { :name => 'Counterspell' )
    #
    # @return [Net::HTTPResponse] The HTTP response object
    #
    # @since 1.2.0
    #
    def get(path, query = {})
      response = get_with_cache URI::Generic.build(:path => path, :query => to_query(query)).to_s
      response = get_with_cache response['Location'] while response.is_a?(Net::HTTPRedirection)
      response
    end

    ##
    # Wrapper for making get requests to Gatherer through our cache.
    #
    # @author Eric Cohen
    #
    # @param [String] uri The uri to make a request to (eg. "/Pages/Default.aspx")
    #
    # @return [Net::HTTPResponse] The HTTP response object
    #
    # @since 1.2.0
    #
    def get_with_cache(uri)
      Scapeshift.configuration.cache.fetch [:gatherer_access, :get, uri] do
        connection.start unless connection.started?
        connection.get uri
      end
    end

    ##
    # Utility method for converting a hash to a proper URI query string encoding its components.
    #
    # Example:
    #
    # to_query(:key => 'value', :another_key => 'another_value')
    # #=> 'key=value&another_key=another_value'
    #
    # @param [Hash] query The query parameters in a hash (eg. { :name => 'Counterspell' )
    #
    # @return [String] The encoded query string
    #
    # @author Eric Cohen
    #
    # @since 1.2.0
    #
    def to_query(hash = {})
      hash.map { |key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join('&') unless hash.empty?
    end

    ##
    # The HTTP connection to Gatherer.
    #
    # @return [Net::HTTP] The HTTP connection
    #
    # @author Eric Cohen
    #
    # @since 1.2.0
    #
    def connection
      @connection ||= Net::HTTP.new 'gatherer.wizards.com'
    end
  end
end
