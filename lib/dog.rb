class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    return self
  end
  
  def self.create(hash)
    dog = Dog.new(name: hash[:name], breed: hash[:breed])
    dog.save
    
    return dog
  end
  
  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    
    return dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    
    dog = DB[:conn].execute(sql, id)[0]
    return Dog.new_from_db(dog)
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    
    dog = DB[:conn].execute(sql, name, breed)[0]
    
    if dog == nil
      Dog.create(name: name, breed: breed)
    else
      return Dog.new_from_db(dog)
    end
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? 
    SQL
    
    dog = Dog.new_from_db(DB[:conn].execute(sql, name)[0])
    
    return dog
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @album, @id)
  end
end