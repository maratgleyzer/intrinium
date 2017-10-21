module Intrinium

##set intrinio api endpoints
  COMPANIES_URI = "/companies"
  SECURITIES_URI = "/securities"
  HISTORICAL_DATA_URI = "/historical_data"
  HISTORICAL_PRICING_URI = "/prices"

##set common api query keys
  TICKER_KEY = "ticker"
  PAGE_SIZE_KEY = "page_size"
  PAGE_NUMBER_KEY = "page_number"

##set api uri and config file path
##config file is relative to caller
  API_URI = "https://api.intrinio.com"
  CONFIG_FILE = "./lib/intrinium.config"





#####################################
##intrinio service connection adapter
##finds user and pass in config file
##implements credentials to connect
##instantiates the connection object
#####################################
##requires the faraday HTTP library
##faraday requires HTTP and PERSISTENT
##faraday requires faraday middleware 
#####################################
  class ADAPTER 

    require 'net/http'
	require 'net/http/persistent'
	require 'faraday'
	require 'faraday_middleware'
	require 'json'

	@username = ""
	@password = ""
	@connection = ""

	attr_accessor :username
	attr_accessor :password
	attr_accessor :connection

	def initialize

	  self.config
	  self.connect

	end

	def config

	credentials = []
	File.open(CONFIG_FILE).readlines.each do |line|
	  credentials << line.split("||")
	end

	@username = credentials[0][1].to_s.gsub("\r\n","")
	@password = credentials[1][1].to_s.gsub("\r\n","")

	end

	def connect

	@connection = Faraday.new(:url => API_URI) do |faraday|
	      faraday.request  :url_encoded             # form-encode POST params
	      faraday.response :logger                  # log requests to STDOUT
	      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
	      faraday.basic_auth(self.username, self.password)
	end #end do


	end

  end












  class COMPANIES

  	def all(adapter, page_size, page_number, pages)

  	  companies = []
	  i = page_number.to_i
	  pages = i + pages.to_i

	  loop do

	    result = adapter.connection.get "#{COMPANIES_URI}?#{PAGE_SIZE_KEY}=#{page_size}&#{PAGE_NUMBER_KEY}=#{i}"
      
	    body = JSON.parse(result.body)

  	    j = body["total_pages"].to_i

        body["data"].each do |data|
      	  companies << data
	    end #end each

	    sleep(0.01)

	    break if i +1 > pages.to_i

	    break if i > j

	    i = i +1

  	  end #end do

	  return companies

    end #end all











    def one(adapter, ticker)

	    result = adapter.connection.get "#{COMPANIES_URI}?#{TICKER_KEY}=#{ticker}"
      
	    company = JSON.parse(result.body)

	    return company

  	end
  
  end









end