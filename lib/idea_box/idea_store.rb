require 'yaml/store'

class IdeaStore

  def self.create(data, time)
    database.transaction do
      database['ideas'] << data.merge("created_at" => time)
    end
  end

  def self.all
    ideas = []
    raw_ideas.each_with_index do |data, i|
      ideas << Idea.new(data.merge("id" => i))
    end
    ideas
  end

  def self.raw_ideas
    database.transaction do |db|
      db['ideas'] || []
    end
  end

  def self.database
    return @database if @database

    @database = YAML::Store.new('db/ideabox')
    @database.transaction do
      @database['ideas'] ||= []
    end
    @database
  end

  def self.delete(position)
    database.transaction do
      database['ideas'].delete_at(position)
    end
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea.merge("id" => id))
  end

  def self.find_raw_idea(id)
    database.transaction do
      database['ideas'].at(id)
    end
  end

  def self.update(id, data)
    database.transaction do
      database['ideas'][id] = data
    end
  end

  def self.ideas_grouped_by_days
    all.group_by { |idea| idea.created_at.strftime("%A") }
  end

  def self.ideas_grouped_by_hours
    all.group_by { |idea| idea.created_at.strftime("%H:00 %p") }
  end

  def self.ideas_grouped_by_category
    all.group_by { |idea| idea.category }
  end
end
