# Puma Pool Usage

A Puma plugin that interprets usage statistics for the percentage of your resources under load. Uses Rails to log this statistic. Inspired by Heroku's pool usage statistic.

Look at this neat log:

    source=PUMA pid=74840 sample#puma.pool_usage=0.8

If your web server is fielding no requests, usage will be 0.0 (0%). If every single resource has a request, usage will be 1.0 (100%). If you have a backlog of requests that cannot be processed because no resources are available, usage can be over 100% (like 1.4).

Wish to chart this data, setup alerts, or scale your servers based on it? Great idea, but it's beyond the scope of this plugin. This plugin provides the data, what you do with the data is up to you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "puma-pool-usage"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install puma-pool-usage

## Usage

In your Puma configuration file (config/puma.rb), add the following line:

```ruby
plugin :pool_usage
```

Restart your server and you're all set. 

## Configuration

By default, Puma Pool Usage will log every Puma worker every 60 seconds. You can configure this via the environment variable `PUMA_STATS_FREQUENCY`. To gather this data only every 5 minutes, set your environment like so:

    PUMA_STATS_FREQUENCY=300

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/simplymadeapps/puma-pool-usage. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Puma::Pool::Usage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/simplymadeapps/puma-pool-usage/blob/master/CODE_OF_CONDUCT.md).
