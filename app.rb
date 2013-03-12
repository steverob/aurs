
require 'sinatra'
require 'yaml'



configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
end

helpers do
  def write_to_buffer(results,dummy)
    File.open("tmp/buffer.yml", "w") {|f| f.write(results.to_yaml) }
  end

  def read_from_buffer
    YAML.load(File.open("tmp/buffer.yml", "r"))
  end
end


get '/' do
  erb :index
end
post '/details' do
  if params[:site]=="schools9"
    redirect to "/schools9_details"
  end
end

get "/schools9_details" do
  erb :schools9_details
end

post '/schools9_scrape' do
  scraper=Schools9.new(params[:url],params[:start],params[:end])
  scraper.scrape
  session[:start]=params[:start]
  session[:end]=params[:end]
  write_to_buffer(scraper.results,0)
  redirect to "/results"
end

get "/results" do

  @results=read_from_buffer
  @start=session[:start]
  @end=session[:end]
  erb :results
end


require_relative 'lib/schools9'
