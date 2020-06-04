require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(attr_hash)
        @id = attr_hash[:id]
        @name = attr_hash[:name]
        @breed = attr_hash[:breed]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
        SQL
        
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attr_hash)
        new_dog = Dog.new({id: attr_hash[:id], name: attr_hash[:name], breed: attr_hash[:breed]})
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        new_dog = self.new({id: row[0], name: row[1], breed: row[2]})
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE id = ?
        SQL

        result = DB[:conn].execute(sql, id).first
        new_dog = self.new({id: result[0], name: result[1], breed: result[2]})
    end

    def self.find_or_create_by(attr_hash)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        new_dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])

        if !new_dog.empty?
            dog_data = new_dog[0]
            new_dog = self.new({id: dog_data[0], name: dog_data[1], breed: dog_data[2]})
          else
            new_dog = self.create({name: attr_hash[:name], breed: attr_hash[:breed]})
          end
          new_dog

    end

    def self.find_by_name(search_name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL
        result = DB[:conn].execute(sql, search_name).first
        # binding.pry
        new_dog = self.new({id: result[0], name: result[1], breed: result[2]})

    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

    end

end