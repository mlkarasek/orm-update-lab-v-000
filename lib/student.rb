require_relative "../config/environment.rb"

class Student

attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE if NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students(name, grade) VALUES(?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
end

  def self.new_from_db(row)
    student_new = self.new
    student_new.id = row[0]
    student_new.name = row[1]
    student_new.grade = row[2]
    student_new
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM students WHERE name = ? LIMIT 1
  SQL
  result = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first 
end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
