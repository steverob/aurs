
require 'sinatra'




configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
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
  session[:results]=scraper.results
  session[:start]=params[:start]
  session[:end]=params[:end]
  redirect to "/results"
end

get "/results" do
  
  @results=session[:results]
  @start=session[:start]
  @end=session[:end]
  erb :results
end


require_relative 'schools9'
