require 'mechanize'

class ChennaiResults
  attr_accessor :results

  def initialize(url,start,ending)
    @url=url
    @start=start.to_i
    @ending=ending.to_i
    @count=0
    @reg_nos=Array.new
    @results=Hash.new
    @agent=Mechanize.new
    generate_reg_nos
  end

  protected
    def generate_reg_nos
      reg=@start
      while reg!=@ending+1
        @reg_nos << reg
        reg+=1
      end
    end

#    def process_url
#      @url.gsub!(File.extname(@url),".aspx")
#    end

  public

  def scrape

    @reg_nos.each do |reg_no|

      @agent.post(@url,:rollno=>reg_no)

      data=@agent.page.search('td')

      @results[reg_no]={}
      @results[reg_no][:grades]={}

      data.each_with_index do |t,i|
        if t.nil?
          next
        elsif data[i+1].nil?
          break
        elsif t.text=='Personal Details'
          next
        elsif t.text=='Registration No. '
          #puts "Registration Number: #{data[i+1].text}"
          next
        elsif data[i-1].text=='Registration No. ' || data[i-1].text=='Name'
          next
        elsif t.text=="Degree & Branch " || t.text=~ /B.E.(.*)/ || t.text=="Subject" || t.text=="Grade" || t.text=="Result"
          next
        elsif t.text=='Name'
          @results[reg_no][:name]=data[i+1].text
        elsif t.text=="PASS" || t.text=="RA" || t.text=="A"|| t.text=="B"|| t.text=="C"|| t.text=="D"|| t.text=="E"|| t.text=="S"|| t.text=="U"|| t.text=~ /WH(.*)/ || t.text=="AB"|| t.text=="W"|| t.text=="SA" || t.text=="SE"|| t.text=="A.B"|| t.text=="I"|| t.text=="WD"|| t.text==" "|| t.text=="BRK"|| t.text==""
          next
        else
          @results[reg_no][:grades][data[i].text]={:grade=>data[i+1].text,:result=>data[i+2].text}
        end
      end
      if @results[reg_no][:name].nil?
        @results.delete(reg_no)
      end
      @count+=1
    end
  end

end
