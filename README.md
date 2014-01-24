# Dr. JSON

Closes abruptly cut-off JSON strings.

## Installation

Install the gem:

    $ gem install drjson

Or add this line to your application's Gemfile:

    gem 'drjson'

And then execute:

    $ bundle

## Usage

You can hand over your poor JSON over command line

    $ echo '{"foo":nul' | drjson 
    {"foo":null}

    $ echo -n '[7, [42' | drjson
    [7, [42]]

or via file

    $ echo -n '{"foo": {"bar"' > my_file.json
    $ drjson my_file.json
    {"foo": {"bar":null}}

## State of Code

[![Build Status](https://secure.travis-ci.org/mat/drjson.png)](http://travis-ci.org/mat/drjson) [![Code Climate](https://codeclimate.com/github/mat/drjson.png)](https://codeclimate.com/github/mat/drjson)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
