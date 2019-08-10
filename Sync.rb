require 'dotenv/load'
require 'uri'
require 'net/http'
require 'rexml/document'
require 'json'

Dir['*.rb'].each {|file| require_relative file}

def handler(event:, context:)
  hatena_entries = Hatena.get_entries
  qiita_entries = Qiita.get_entries
  hatena_entries.each do |hatena_entry|
    Qiita.post(hatena_entry) unless hatena_entry.included?(qiita_entries)
  end
end
