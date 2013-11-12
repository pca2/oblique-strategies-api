# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

# Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
# set, when working locally this line will fall back to using SQLite in the
# current directory.
# DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")
DataMapper.setup(:default, ENV['DATABASE_URL'])

# Define a simple DataMapper model.
class Thing
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :edition, Integer
  property :cardnumber, Integer
  property :strategy, Text

  # property :title, String
  # property :description, Text
end

# Finalize the DataMapper models.
DataMapper.finalize

# Tell DataMapper to update the database according to the definitions above.
DataMapper.auto_upgrade!

# get '/stylesheets/style.css' do
#   content_type 'text/css', :charset => 'utf-8'
#   sass :style
# end

get '/' do
  # send_file './public/index.html'
  haml :index
end

# Route to show all Things, ordered like a blog
get '/all' do
  content_type :json
  @things = Thing.all(:order => :id)

  @things.to_json
end

get '/edition/:edition/all' do
  content_type :json
  @things = Thing.all(:edition => params[:edition].to_i)

  if @things
    @things.to_json
  else
    halt 404
  end
end

get '/edition/:edition/draw' do
  content_type :json
  @things = Thing.all(:edition => params[:edition].to_i)
  @thing = @things.first(:offset => rand(@things.count))

  if @thing
    @thing.to_json
  else
    halt 404
  end
end

get '/draw' do
  content_type :json
  @things = Thing.all()
  @thing = @things.first(:offset => rand(@things.count))

  @thing.to_json
end

get '/card' do
  @things = Thing.all()
  @thing = @things.first(:offset => rand(@things.count))

  haml :card
end

# CREATE: Route to create a new Thing
post '/' do
  content_type :json

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  # params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.
  @thing = Thing.new(params)

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end


# READ: Route to show a specific Thing based on its `id`
get '/edition/:edition/cardnumber/:cardnumber' do
  content_type :json
  @thing = Thing.first(:edition => params[:edition].to_i, :cardnumber => params[:cardnumber].to_i)

  if @thing
    @thing.to_json
  else
    halt 404
  end
end


# READ: Route to show a specific Thing based on its `id`
get '/id/:id' do
  content_type :json
  @thing = Thing.first(:id => params[:id].to_i)

  if @thing
    @thing.to_json
  else
    halt 404
  end
end

# # UPDATE: Route to update a Thing
# put '/things/:id' do
#   content_type :json

#   # These next commented lines are for if you are using Backbone.js
#   # JSON is sent in the body of the http request. We need to parse the body
#   # from a string into JSON
#   # params_json = JSON.parse(request.body.read)

#   # If you are using jQuery's ajax functions, the data goes through in the
#   # params.

#   @thing = Thing.get(params[:id])
#   @thing.update(params)

#   if @thing.save
#     @thing.to_json
#   else
#     halt 500
#   end
# end

# # DELETE: Route to delete a Thing
# delete '/things/:id/delete' do
#   content_type :json
#   @thing = Thing.get(params[:id])

#   if @thing.destroy
#     {:success => "ok"}.to_json
#   else
#     halt 500
#   end
# end

# If there are no Things in the database, add a few.
if Thing.count == 0
  # add things from txt file / csv / whatever
  (1..4).each do |edition|
    index = 1
    File.open("./editions/" + edition.to_s, "r").each_line do |line|
      Thing.create(:edition => edition, :strategy => line.chomp, :cardnumber => index)
      index += 1
    end
  end

  # Thing.create(:edition => 1, :strategy => "Abandon normal instruments")
  # Thing.create(:edition => 2, :strategy => "A line has two sides")
  # Thing.create(:edition => 2, :strategy => "Balance the consistency principle with the inconsistency principle")
  # Thing.create(:edition => 2, :strategy => "Change nothing and continue with immaculate consistency")
  # Thing.create(:edition => 3, :strategy => "Allow an easement (an easement is the abandonment of a stricture)")

  # Thing.create(:title => "Test Thing One", :description => "Sometimes I eat pizza.")
  # Thing.create(:title => "Test Thing Two", :description => "Other times I eat cookies.")
end