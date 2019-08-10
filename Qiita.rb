class Qiita
  @base_uri = 'https://qiita.com/api/v2'

  def self.get_entries
    entries = []
    uri = URI.parse(@base_uri + '/authenticated_user/items')

    Net::HTTP.start(uri.host, use_ssl: true) do |http|
      page = 1
      begin
        params = {page: page, per_page: 20}
        uri.query = URI.encode_www_form(params)
        req = Net::HTTP::Get.new(uri)
        authorize(req)
        res = http.request(req)
        body = JSON.parse(res.body)
        
        body.each do |item|
					entry = Entry.new
          entry.id = item["id"]
          entry.title = item["title"]
          entry.content = item["rendered_body"]
          item["tags"].each do |tag|
            entry.tags << tag["name"]
          end
          entries << entry
        end
        page += 1
      end while res["Link"].include?('next')
    end
    entries
  end

  def self.post(entry)
    uri = URI.parse(@base_uri + '/items')

    Net::HTTP.start(uri.host, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      authorize(req)
      req.body = {
        "body":    entry.content,
        "private": false,
        "tags":    entry.tags.select{|tag| tag != 'SyncQiita'}.map {|tag| {"name" => tag}},
        "title":   entry.title,
        "tweet":   false
      }.to_json
      res = http.request(req)
    end
  end

  private

  def self.authorize(req)
    req["Authorization"] = "Bearer #{ENV['QIITA_ACCESS_TOKEN']}"
  end
end
