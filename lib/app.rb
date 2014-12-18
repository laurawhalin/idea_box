require 'bundler'
Bundler.require

require 'idea_box'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  register Sinatra::Partial
  set :partial_template_engine, :erb

  configure :development do
    register Sinatra::Reloader
  end

  not_found do
    erb :error
  end

  get '/' do
    @categories = ['Default', 'Good Idea', 'Bad Idea', 'Million Dollar Idea']
    @list_ideas = IdeaStore.all.sort
    erb :index, locals: {idea: Idea.new(params)}
  end

  post '/' do
    IdeaStore.create(params[:idea], Time.now)
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    @categories = ['Default', 'Good Idea', 'Bad Idea', 'Million Dollar Idea']
    @idea = IdeaStore.find(id.to_i)
    idea = IdeaStore.find(id.to_i)
    require 'pry' ; binding.pry
    erb :edit, locals: {idea: idea}
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
    erb :statistics, locals: {ideas_grouped_by_hours: IdeaStore.ideas_grouped_by_hours, ideas_grouped_by_days: IdeaStore.ideas_grouped_by_days}
  end

  get '/categories' do
    if params[:idea] && params[:idea][:category]
      @list_ideas = IdeaStore.ideas_selected_by_category(params[:idea][:category]) #returns a hashes
    else
      @list_ideas = IdeaStore.all.sort #returns an array
    end
    @categories = ['Default', 'Good Idea', 'Bad Idea', 'Million Dollar Idea']
    erb :categories
  end

  get '/categories/:category' do |category|
    erb :categories, locals: {category: category, ideas_selected_by_category: IdeaStore.ideas_selected_by_category(category)}
  end
end
