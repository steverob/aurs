require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'


doc=Nokogiri::HTML(open("http://schools9.com/anna-university-grade-system-exam-results.aspx?htno=23009104071"))
cells=doc.css("td")
reg_no=23009104071
results=Hash.new
results[reg_no]={}
      cells.length.times do |i|

        if cells[i].text==" Hall Ticket No "
           next
        elsif cells[i-1].text==" Hall Ticket No "
          next
        elsif cells[i-1].text==" Course "
          next
        elsif cells[i].text==" Name "
          
          results[reg_no][:name]=cells[i+1].text
          
          
          next
        elsif cells[i].text==" Course " || cells[i].text=~ /B.E.(.*)/ || cells[i].text=="Marks Details" || cells[i].text=="Subject" || cells[i].text=="Grade" || cells[i].text=="Status"
         # puts i
          next
        elsif cells[i].text=="PASS" || cells[i].text=="RA" || cells[i].text=="A"|| cells[i].text=="B"|| cells[i].text=="C"|| cells[i].text=="D"|| cells[i].text=="E"|| cells[i].text=="S"|| cells[i].text=="U"|| cells[i].text=~ /WH(.*)/ || cells[i].text=="AB"|| cells[i].text=="W"|| cells[i].text=="SA" || cells[i].text=="SE"|| cells[i].text=="A.B"|| cells[i].text=="I"|| cells[i].text=="WD"|| cells[i].text==" "
          next
        elsif cells[i+1].text==" Course "
          next
        else
          
          results[reg_no][cells[i].text]={:grade=>cells[i+1].text,:result=>cells[i+2].text}
          
          
        end
      end
puts results
