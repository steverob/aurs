require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'


class Schools9
  attr_accessor :results
  
  def initialize(url,start,ending)
    @url=url
    @start=start.to_i
    @ending=ending.to_i
    @count=0
    @reg_nos=Array.new
    @results=Hash.new
    generate_reg_nos
    process_url
  end
  
  protected
    def generate_reg_nos
      reg=@start
      while reg!=@ending+1
        @reg_nos << reg
        reg+=1
      end
    end
    
    def process_url
      @url.gsub!(File.extname(@url),".aspx")
    end
  
  public 
  
  def scrape
  
    @reg_nos.each do |reg_no|
      doc=Nokogiri::HTML(open("#{@url}?htno=#{reg_no}"))
      cells=doc.css("td")

      @results[reg_no]={}
      @results[reg_no][:grades]={}
      
      cells.length.times do |i|
        if cells[i].text==" Hall Ticket No "
          next
        elsif cells[i-1].text==" Hall Ticket No "
          next
        elsif cells[i-1].text==" Course "
          next
        elsif cells[i].text==" Name "
          @results[reg_no][:name]=cells[i+1].text
          next
        elsif cells[i].text==" Course " || cells[i].text=~ /B.E.(.*)/ || cells[i].text=="Marks Details" || cells[i].text=="Subject" || cells[i].text=="Grade" || cells[i].text=="Status"
          next
        elsif cells[i].text=="PASS" || cells[i].text=="RA" || cells[i].text=="A"|| cells[i].text=="B"|| cells[i].text=="C"|| cells[i].text=="D"|| cells[i].text=="E"|| cells[i].text=="S"|| cells[i].text=="U"|| cells[i].text=~ /WH(.*)/ || cells[i].text=="AB"|| cells[i].text=="W"|| cells[i].text=="SA" || cells[i].text=="SE"|| cells[i].text=="A.B"|| cells[i].text=="I"|| cells[i].text=="WD"|| cells[i].text==" "
          next
        elsif cells[i+1].text==" Course "
          next
        else
          @results[reg_no][:grades][cells[i].text]={:grade=>cells[i+1].text,:result=>cells[i+2].text}
        end
      end
      @count+=1
    end
  end
  
end

