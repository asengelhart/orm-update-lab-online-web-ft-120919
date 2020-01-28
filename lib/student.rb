require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    id, name, grade = row[0..2]
    new(name, grade, id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?;"
    row = DB[:conn].execute(sql, name)[0]
    new_from_db(row)
  end

  def update
    return nil if self.id == nil
    sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
    self
  end

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
      self
    end
  end
end
