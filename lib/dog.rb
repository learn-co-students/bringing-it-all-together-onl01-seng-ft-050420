class Dog
   attr_accessor :name, :breed
    attr_reader :id
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end
    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end
    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end
    def save
        if @id
            self
        else
       sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
        DB[:conn].execute(sql, @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
        end
    end
    def self.create(name:, breed:)
       Dog.new(name: name, breed: breed).save 
    end
    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end
    def self.find_by_id(id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)
        Dog.new_from_db(row[0])
    end
    def self.find_or_create_by(name:, breed:)
         row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if row.empty?
            Dog.create(name: name, breed: breed)
        else
            Dog.find_by_id(row[0][0])
        end
    end
    def  self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        Dog.new_from_db(row[0])
    end
    def update
       sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, @name, @breed, @id)
    end
end