require 'json'
require 'nokogiri'
require 'open-uri'
require 'ruby-prof'

RubyProf.start

BASE_URL = ""              # '.something.ru'
ITEMS_LINK = ""            # '/items/all'
ITEM_LIST_SELECTOR = ""    # 'ul.items>li.item'
DESCRIPTION_PATH = ""      # './div/p'

@prefixes = []
File.open("prefixes.txt", "r") do |infile|
    infile.each do |line|
      name, link = line.chomp.split("\t")
      @prefixes << { name: name, link: "https://" + "#{link}" + BASE_URL }
    end
end

@out_file = File.new("output/output.csv", "w")
def get_items_for_prefix(prefix)
  full_url = prefix[:link] + ITEMS_LINK
  doc = Nokogiri::HTML(open(full_url))
  doc.css(ITEM_LIST_SELECTOR).each do |sector|      
    name = sector.content.strip
    link = sector['href']
    description = sector.at_xpath(DESCRIPTION_PATH).content.strip    
    @out_file.write( "#{name}\t#{prefix}\t#{description}\t#{link}\n" )
  end
end

threads = []
@prefixes.each do |prefix|
  threads << Thread.new do
    get_items_for_prefix(prefix)
  end
end
threads.each(&:join)
@out_file.close

result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
