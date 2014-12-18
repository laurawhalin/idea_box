class Idea
  include Comparable
  attr_reader :title, :description, :rank, :id, :created_at, :category

  def initialize(attributes)
    @title       = attributes["title"]
    @description = attributes["description"]
    @rank        = attributes["rank"] || 0
    @id          = attributes["id"]
    @created_at  = attributes["created_at"]
    @category    = attributes["category"]
  end

  def save
    IdeaStore.create(to_h)
  end

  def to_h
    {
      "title"       => title,
      "description" => description,
      "rank"        => rank,
      "id"          => id,
      "created_at"  => created_at,
      "category"    => category
    }
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    other.rank <=> rank
  end
end
