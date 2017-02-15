require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_reader :id
  attr_accessor :name, :grade
  def initialize(name, grade, id=nil)
    @name=name
    @grade=grade
    @id=id
  end

  def self.create_table
    sql= <<-SQL
      CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql= "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql=<<-SQL
      INSERT INTO students
      (name, grade) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id= DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student= self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    create(row[1], row[2])
  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM students
      WHERE name=?
      SQL
      results=DB[:conn].execute(sql, name).flatten
      Student.new(results[1], results[2], results[0])
    end

  def update
    sql=<<-SQL
      UPDATE students
      SET name=?, grade=?
      WHERE id=?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
