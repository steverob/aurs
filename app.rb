
require 'sinatra'
require 'yaml'
require 'json'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  auth=YAML.load_file('config.yml')
  [username, password] == [auth["username"], auth["password"]]
end

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
end

helpers do
  include Rack::Utils

  def write_to_buffer(results,dummy)
    File.open("tmp/buffer.yml", "w") {|f| f.write(results.to_yaml) }
  end

  def read_from_buffer
    YAML.load(File.open("tmp/buffer.yml", "r"))
  end

  alias_method :h, :escape_html

end


get '/' do
  erb :index
end
post '/details' do
  if params[:site]=="schools9"
    redirect to "/schools9_details"
  elsif params[:site]=="chennaieducation"
    redirect to "/chennai_edu_details"
  end
  erb "<br /><br /><br />Support not available yet. If you're interested in writing a class for this website please refer github: <a href='http://github.com/steverob/aurs'>steverob/aurs</a><br /><a href='/'>Go Back</a>"
end

get "/schools9_details" do
  erb :schools9_details
end

get "/chennai_edu_details" do
  erb :chennai_edu_details
end

post "/wait" do
  @start=params[:start]
  @ending=params[:end]
  if params[:site]=="schools9"
    @url="/schools9_scrape?url="+params[:url]+"&start="+@start+"&"+"end="+@ending
  elsif params[:site]=="chennai_edu"
    if File.extname(params[:url])==""
      redirect to "/chennai_edu_details"
    end
    @url="/chennai_edu_scrape?url="+params[:url]+"&start="+@start+"&"+"end="+@ending
  end
  erb :wait
end

get '/schools9_scrape' do
  scraper=Schools9.new(params[:url],params[:start],params[:end])
  scraper.scrape
  session[:start]=params[:start]
  session[:end]=params[:end]
  write_to_buffer(scraper.results,0)
  {:count=>scraper.results.keys.length}.to_json
end

get '/chennai_edu_scrape' do
  scraper=ChennaiResults.new(params[:url],params[:start],params[:end])
  scraper.scrape
  session[:start]=params[:start]
  session[:end]=params[:end]
  write_to_buffer(scraper.results,0)
  {:count=>scraper.results.keys.length}.to_json
end

get "/results" do
  @results=read_from_buffer
  @start=session[:start]
  @end=session[:end]
  ToXls.write_to_xls
  erb :results
end

get "/download_xls" do
  file="tmp/results.xls"
  send_file(file, :disposition => 'attachment', :filename => "#{session[:start]}_#{session[:end]}.xls")
  redirect to back
end

get "/about" do
  erb :about
end

require_relative 'lib/schools9'
require_relative 'lib/chennai_results'
require_relative 'lib/to_xls'
