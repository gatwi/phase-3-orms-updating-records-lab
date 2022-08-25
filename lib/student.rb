require_relative "../config/environment.rb"

class Student
  
  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  # initialize

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  # .create_table
  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
        )
    SQL
    DB[:conn].execute(sql)
      end

  # .drop_table
  def self.drop_table 
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end 

  # save
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  # .create
  def self.create(name:, grade:)
    student = Student.new(name, grade)
    student.save
    Student
  end

  # .new_from_db
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end
  
  # .find_by_name
  def self.find_by_name(name) 
    sql = "SELECT * FROM student WHERE name = ?" 
    result = DB[:conn].execute(sql, name)[0]
    Student.new(results[0], result[1], result[2]) 
  end 

  # update
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
