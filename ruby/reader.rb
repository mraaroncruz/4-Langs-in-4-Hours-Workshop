require "bundler/setup"
Bundler.require

require "net/http"
require "uri"

class Reader
  Feed = Struct.new(:url, :title, :authors, :description, :items)

  def initialize(source_path)
    @source_path = source_path
  end

  def fetch
    threads = File.read(@source_path).each_line.map { |url|
      Thread.new {
        fetch_and_parse(url.strip)
      }
    }
    threads.each(&:join)
    threads.map(&:value)
  end

  private

  def fetch_and_parse(url)
    res = Net::HTTP.get_response(URI.parse(url))
    parse(url, res.body)
  end

  def parse(url, raw)
    feed = FeedNormalizer::FeedNormalizer.parse(raw)
    Feed.new(
      url,
      feed.title,
      feed.authors,
      feed.description,
      feed.items
    )
  end
end

reader = Reader.new("./sites.txt")
feeds = reader.fetch

require 'pry'
binding.pry
