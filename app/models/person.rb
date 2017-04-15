require 'net/http'

class Person

  def self.all
    http_get("http://www.bremische-buergerschaft.de/index.php?id=358").search("#abgeordnetenliste > li").map do |person|
      link = person.at("a")
      {
        name:  link.text.squish,
        id:    link['href'].match(/aid=(\d+)/)[1],
        party: person.at("span").text.squish,
      }
    end
  end

  def self.http_get(url)
    res = Net::HTTP.get_response(URI(url))
    raise res.error! unless res.is_a?(Net::HTTPSuccess)
    Nokogiri::HTML res.body
  end


  attr_accessor :page, :source_uri

  def initialize(id)
    @source_uri = "http://www.bremische-buergerschaft.de/index.php?id=358&aid=#{id}"
    @page       = self.class.http_get(@source_uri)
  end

  def panels
    page.search(".ka-panel").map do |panel|
      {
        name:    panel.at(".ka-handler").text,
        content: panel.search(".ka-content li").map(&:text),
      }
    end
  end

  def biography
    page.at("#text_abg p").children.map do |child|
      case child
      when Nokogiri::XML::Text
        child.text
      when Nokogiri::XML::Element
        "\n"
      end
    end.join
  end

  def party
    page.at("#stamm_abg strong").text.squish
  end

  def to_json(*args)
    %w( source_uri biography panels party ).map{|key| [key, send(key)] }.to_h.to_json(*args)
  end

end
