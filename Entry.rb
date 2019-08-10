class Entry
  attr_accessor :id, :title, :content, :tags

  def initialize
    @tags = []
  end

  def post_to_qiita
    Qiita.post(entry)
  end

  def included?(entries)
    entries.any? do |entry|
      title == entry.title
    end
  end
end
