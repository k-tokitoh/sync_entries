# frozen_string_literal: true

class Hatena
  @base_uri = 'https://blog.hatena.ne.jp/tsuzuki670/tamani.hatenadiary.jp/atom'

  def self.retrieve_entries
    entries = []
    uri = URI.parse(@base_uri + '/entry')
    query = ''

    Net::HTTP.start(uri.host, use_ssl: true) do |http|
      begin
        uri.query = query
        req = Net::HTTP::Get.new(uri)
        req.basic_auth(ENV['HATENA_ID'], ENV['HATENA_API_KEY'])
        response = http.request(req)
        elements = REXML::Document.new(response.body).elements

        elements.each('feed/entry') do |elem_entry|
          # 公開済みの記事のみを取得する
          next if elem_entry.elements['app:control/app:draft'].text == 'yes'

          entry = Entry.new
          entry.id = elem_entry.elements['id'].text
          entry.title = elem_entry.elements['title'].text
          entry.content = elem_entry.elements['content'].text
          elem_entry.elements.each('category') do |elem_category|
            entry.tags << elem_category.attributes['term']
          end
          entries << entry if entry.tags.include?('SyncQiita')
        end

        if (next_elem = elements["feed/link[@rel='next']"])
          query = URI.parse(next_elem.attributes['href']).query
        end
      end while next_elem
    end
    entries
  end
end
