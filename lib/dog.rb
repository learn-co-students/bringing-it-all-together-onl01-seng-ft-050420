
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  @@all = []

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed) #initialze an object
    dog.save #create an entry in the database
    dog
  end

  def save
    if self.id #if this object's data exist in the database then update the entry
      self.update
    else #if this object's data does not exist in the database, create a new entry
      sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create_table #execute the create table statement
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table #execute the drop table statement
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row) #intialize an object with an entry's date from the database
    dog = self.new(id:row[0], name:row[1], breed:row[2])
  end



  def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id) #update an entry's data based off of unchangeable id attr
  end



  def self.find_by_id(id) #search for a database entry by id and create an object from the data in that entry
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
  end

  def self.find_by_name(name) #search for a database entry by name and create an object from the data in that entry
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id:result[0], name:result[1], breed:result[2])
  end

  def self.find_or_create_by(name:, breed:) #better than .find_by_name. Doesn't allow duplicate
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty? #if the database entry exist, then initialize an object with the entry's data
      dog_data = dog[0]
      dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else #if the entry doesn't exist, create the object and save/create an entry in the database with .create
      dog = self.create(name: name, breed: breed)
    end
    dog
  end














end
