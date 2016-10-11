require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'sinatra/flash'
require "sendgrid-ruby"

enable :sessions

configure :development do
  set :database, 'sqlite3:db/database.db'
end 
require './models'

# --- Variables ---
@loggedin = false;

# --- GETS ---

# Global Var go here
before do 
		# Product Info
		@products = [ {name: "Blaster", img: "blaster.jpg", description: "Pew pew pew!", price: "660,000"},
			{name: "Saber", img: "lightsaber.jpg", description: "Swosh swosh!", price: "500,345"},
			{name: "Hammer", img: "hammer.jpg", description: "Thuuuud......THUUUD!", price: "999,000"},
			{name: "Reactor", img: "reactor.jpg", description: "humnznznznznznznnznzn!", price: "34,000"},
			{name: "Recorder", img: "talkie.jpg", description: "Sul sul. Zo hungwah Ne chumcha laka fruby nart.", price: "456,000"},
			{name: "Hook", img: "hook.jpg", description: "puhhh shhshshhsh dadehda cring.", price: "230,000"},
			{name: "Pickaxe", img: "pickaxe.jpg", description: "Whoops.", price: "456,000"} ];
end

get '/' do
	erb :'/front'
end

# Main navigation
get '/:name' do

	# If session exists/(signed in) then find user
	if session[:id] != nil
		@user = User.find(session[:id]);
		@loggedin = true;


		case params[:name]
		when "home"
			erb :home;
		when "about"
			erb :about;
		when "product"
			erb :product;
		when "cart"
			@user = User.find_by_id(session[:id])
			erb :cart;
		when "logout"
			session.clear
			erb :logout;
		else
			erb :Error404;
		end
	else
		@loggedin = false;

		# If not signed in then
		case params[:name]
		when "signup"
			erb :signup;
		when "login"
			erb :login;
		else
			redirect '/';
		end

		# @error = 'you are not signed in'
	end
end

# --- POSTS ---

# SIGN UP
post '/sign' do
	puts params["email"]
	
	if User.exists?(email: params["email"]) || User.exists?(username: params["username"])
		flash[:error] = "Email or Username is already taken. Please try again";
		redirect :signup;
	else
		@user = User.new(email: params["email"],username: params["username"], password: params["password"], products: " ");
		@user.save;
		session[:id] = @user.id;
		redirect :home;;
	end
end

# Login
post '/login' do
	if User.exists?(password: params["password"]) && User.exists?(email: params["email"])
		# pass and username exit
		@user = User.find_by(email: params["email"], password: params["password"])
		session[:id] = @user.id;
		redirect :home;
	else
		# Could not find username or password
		flash[:error] = "Email or Password are incorrect. Please try again";
		redirect :login;
	end

end

# Returns Product array in json format
post '/getdata' do
	@products.to_json
end

post '/add' do
	@data = params["data_value"]
	@user = User.find_by_id(session[:id]) 
	@user.update_attributes(products: @data)
end

post '/contact' do

end

post '/cart' do
	@user = User.find_by_id(session[:id]) 
	@user.update_attributes(products: " ")
	flash[:confirm] = "Thanks for shopping at Arget. We will send you confimation of your order ASAP"
	redirect :cart;
end
