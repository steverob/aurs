require 'spreadsheet'
require 'yaml'

class ToXls

  def self.write_to_xls
    results=YAML.load(File.open('tmp/buffer.yml','r'))

    grades=Array.new
    results.each do |k,v|
      grades << v[:grades].keys
    end
#    puts results
#    puts "==========================================="
#    puts grades
#    puts "00000000000000"
#    grades=grades.reject { |arr| arr.length==0}
#    puts grades
#    puts "00000000000000"
    grades=grades.inject(&:&)
#    puts grades
#    puts "00000000000000"


    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    format = Spreadsheet::Format.new :weight => :bold, :size => 11
    sheet1.row(0).default_format = format

    sheet1.name = 'Mark List'
    sheet1.row(0).push("Reg. No.")
    sheet1.row(0).push("Name")
    sheet1.column(0).width=15
    sheet1.column(1).width=30
    grades.each do |grade|
      sheet1.row(0).push(grade)
    end

    i=1
    count=results.length

    results.each do |reg,res|
      sheet1.row(i).push reg,res[:name]
      grades.each do |grade|
        sheet1.row(i).push(res[:grades][grade][:grade])
      end
      i+=1
    end

    book.write 'tmp/results.xls'
  end
end
