require 'pry'
class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table 
    sql = <<-SQL
    Create TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES ( ?, ? )
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.create(atr)
    dog = Dog.new(atr)
    dog.save
  end
  
  def self.new_from_db(row)
   dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', id).flatten
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])\
  end
  
  def self.find_or_create_by(row)
    #binding.pry
    dog =  DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', row[:name], row[:breed]).flatten
    if !dog.empty?
      dog = Dog.new_from_db(dog)
    else
      dog = Dog.create(row)
    end
  end
  
  def self.find_by_name(name)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name).flatten
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def update
    DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?', self.name, self.breed, self.id )
  end
  
end