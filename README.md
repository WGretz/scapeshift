Scapeshift
==========

Scapeshift is a webscraper rubygem designed for the Magic: The Gathering Oracle "Gatherer" card index.
Since Wizards doesn't want to make an API for this system for various reasons, I've gone ahead and made
a pseudo-API here.

Scapeshift uses the delightful Nokogiri gem to parse and scrape the various Oracle pages, generating 
(most commonly) a SortedSet of Scapeshift::Card objects containing the card data. In the case of expansion sets, formats, 
etc. Scapeshift returns a SortedSet of strings.

Usage
-----

Usage is as simple as can be:

```ruby
# Grab the complete list of expansion sets
@sets = Scapeshift::Crawler.crawl :meta, :type => :sets

# Grab the card set for an expansion
@alara_cards = Scapeshift::Crawler.crawl :cards, :set => 'Shards of Alara'

# Grab a single named card
@card = Scapeshift::Crawler.crawl :single, :name => 'Counterspell'
```

Configuration
-------------

The gem can be easily configured with a `Scapeshift.configure` block (currently on the cache store option is available):

```ruby
Scapeshift.configure do |config|
  config.cache = :memory_store
end
```

Caching
-------

By default requests to the Gatherer website are cached in memory using ActiveSupport's
[MemoryStore](http://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html)
but that can be easily configured.

To change to a memcache server simply:

```ruby
Scapeshift.configure do |config|
  config.cache = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
end
```

You will need to install the `memcache-client` gem to do so.

You can also use an existing cache store by passing it as the cache option. For example in a Rails application you
could:

```ruby
Scapeshift.configure do |config|
  config.cache = Rails.cache
end
```

To disable caching *DO NOT* set the cache to `nil` as that will break stuff. Instead use the ActiveSupport's
[NullStore](http://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html) that does the same thing but through
the `ActiveSupport::Cache::Store` API.

See the Rails [Caching Guide](http://guides.rubyonrails.org/caching_with_rails.html#cache-stores) for more info on
configuring different cache stores.

Development
-----------

This gem uses Bundler to manage its dependencies for development:

    $ sudo gem install bundler
    $ cd /path/to/scapeshift
    $ bundle install

Bundler is unlike Rubygems in that it doesn't automagically handle load paths for you. To
make stuff work, you will need to start a subshell with
    
    $ bundle exec bash

Replacing `bash` with the shell of your choice, of course.

TODO
----

* Scraping data issues
    * [Double-faced cards](http://wiki.mtgsalvation.com/article/Double-faced_cards) - examples:
        [Garruk Relentless // Garruk, the Veil-Cursed](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=245250),
        [Delver of Secrets // Insectile Aberration](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=226749)
    * [Flip cards](http://wiki.mtgsalvation.com/article/Flip_cards) - examples:
        [Budoka Gardener // Dokai, Weaver of Life](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=78687),
        [Nezumi Graverobber // Nighteyes the Desecrator](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=247175)
    * [Split cards](http://wiki.mtgsalvation.com/article/Split_cards) - examples:
        [Fire // Ice](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=292753),
        [Research // Development](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=107375)
    * [B.F.M. (Big Furry Monster)](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=9780)
    * [Color indicator](http://wiki.mtgsalvation.com/article/Color_indicator) - examples:
        [Crimson Kobolds](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=201130),
        [Evermind](http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=74144)

Documentation
-------------

This gem uses Yardoc syntax for documentation. You can generate these docs
with `rake yard`. Point any webserver at the `docs/` directory to browse.

Simple, with Thin:

    $ cd /path/to/scapeshift
    $ rake yard
    $ cd docs/
    $ thin -A file -d start

Copyright
---------

Copyright (c) 2010 Josh Lindsey. See LICENSE for details.
