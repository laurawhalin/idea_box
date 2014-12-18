require 'bundler'
Bundler.require

require 'idea_box'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all.sort, idea: Idea.new(params), categories: IdeaStore.category_options}
  end

  post '/' do
    IdeaStore.create(params[:idea], Time.now)
    redirect '/'
  end

  not_found do
    erb :error
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: {idea: idea, categories: IdeaStore.category_options}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  get '/statistics' do
    ideas_grouped_by_hours = IdeaStore.all.group_by { |idea| idea.created_at.strftime("%H:00 %p")}
    ideas_grouped_by_days  = IdeaStore.all.group_by { |idea| idea.created_at.strftime("%A")}
    erb :statistics, locals: {ideas_grouped_by_hours: ideas_grouped_by_hours, ideas_grouped_by_days: ideas_grouped_by_days}  #take all the ideas(grouped by hours), then access individual ideas with their time, display the title of that idea in the page
  end


end
