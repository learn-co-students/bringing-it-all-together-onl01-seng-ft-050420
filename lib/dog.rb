class Dog

    attr_accessor :name, :breed, :id

    def initialize(keyvalues_hash)
        @id = keyvalues_hash[:id]
        @name = keyvalues_hash[:name]
        @breed = keyvalues_hash[:breed]
    end
    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGAR PRIMARY KEY,
            name TEXT,
            breed, TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end
    
    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end 

    def save
        sql = <<-SQL
        INSERT INTO dogs(name,breed) VALUES (?, ?)
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        self #returns an instance of the dog class
    end

    def self.create(keyvalues_hash)
        dog = Dog.new(keyvalues_hash)
        dog.save
        dog
    end 

    def self.new_from_db(row)
        new_dog_hash = {}
        new_dog_hash[:id] = row[0]
        new_dog_hash[:name] = row[1]
        new_dog_hash[:breed] = row[2]
        new_dog = self.new(new_dog_hash)
        new_dog
    end 

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        dog = DB[:conn].execute(sql,id)
        new_dog_hash = {}
        new_dog_hash[:id] = dog[0][0]
        new_dog_hash[:name] = dog[0][1]
        new_dog_hash[:breed] = dog[0][2]
        new_dog = self.new(new_dog_hash)
        new_dog     
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0],
            dog_data_hash = {}
            dog_data_hash[:id] = dog_data[0][0]
            dog_data_hash[:name] = dog_data[0][1]
            dog_data_hash[:breed] = dog_data[0][2]
            dog = Dog.new(dog_data_hash)
        else
            dog = self.create(name:name, breed:breed)
        end
        dog    
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql,name)[0]
        dog_data_hash = {}
        dog_data_hash[:id] = result[0]
        dog_data_hash[:name] = result[1]
        dog_data_hash[:breed] = result[2]
        dog = Dog.new(dog_data_hash)
        dog
    end
    
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end  
    

    
end