# frozen_string_literal: true

require "bundler/setup"
Bundler.require
require 'uri'
require 'net/http'
require 'rexml/document'
require 'json'

Dir['*.rb'].each { |file| require_relative file }
Dir['lib/*.rb'].each { |file| require_relative file }

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  hatena_entries = Hatena.retrieve_entries
  qiita_entries = Qiita.retrieve_entries
  hatena_entries.each do |hatena_entry|
    Qiita.post(hatena_entry) unless hatena_entry.included?(qiita_entries)
  end
end
