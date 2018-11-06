require 'sqlite3'
require 'singleton'

class QuestionsDatabaseConnection < SQLite3::Database 
  include Singleton 
  
  def initialize
    super('questions.db')
    
    self.type_translation = true 
    self.results_as_hash = true
  end
end
# =============================================================================================

class Question
  attr_accessor :title, :body, :author
  attr_reader :id
  
  def self.all 
    data = QuestionsDatabaseConnection.instance.execute("SELECT * FROM questions")  
    data.map { |datum| Question.new(datum) }
  end
  
  def self.find_by_id(id) 
    question = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM 
        questions 
      WHERE 
        id = ?
    SQL
    
    return nil unless question.length > 0
    Question.new(question.first)
  end
  
  def self.find_by_author_id(author_id)
    question = QuestionsDatabaseConnection.instance.execute(<<-SQL, author_id)
      SELECT 
      *
      FROM 
        questions
      WHERE 
        author_id = ?
    SQL
    
    return nil unless question.length > 0
    question.map { |question| Question.new(question) }
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author = options['author']
  end
  
  
end
# =============================================================================================

class User
  attr_accessor :fname, :lname
  attr_reader :id
  
  def self.all 
    data = QuestionsDatabaseConnection.instance.execute("SELECT * FROM users")  
    data.map { |datum| User.new(datum) }
  end
  
  def self.find_by_id(id) 
    user = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM 
        users 
      WHERE 
        id = ?
    SQL
    
    return nil unless user.length > 0
    User.new(user.first)
  end
  
  def self.find_by_name(fname, lname) 
    user = QuestionsDatabaseConnection.instance.execute(<<-SQL, fname, lname)
      SELECT 
        *
      FROM 
        users 
      WHERE 
        fname = ? AND lname = ?
    SQL
    
    return nil unless user.length > 0
    User.new(user.first)
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  
end


# =============================================================================================

class QuestionFollow
  attr_accessor :follower_id, :question_id
  
  
  def self.all 
    data = QuestionsDatabaseConnection.instance.execute("SELECT * FROM question_follows")  
    data.map { |datum| QuestionFollow.new(datum) }
  end
  
  def self.find_by_id(id) 
    question = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM 
        question_follows 
      WHERE 
        id = ?
    SQL
    
    return nil unless question.length > 0
    QuestionFollow.new(question.first)
  end
  
  def initialize(options)
    @id = options['id']
    @follower_id = options['follower_id']
    @question_id = options['question_id']
  end
end
  # =============================================================================================

  class Reply
    attr_accessor :question_id, :parent_reply, :author_id, :body
    attr_reader :id
    
    
    def self.all 
      data = QuestionsDatabaseConnection.instance.execute("SELECT * FROM replies")  
      data.map { |datum| Reply.new(datum) }
    end
    
    def self.find_by_id(id) 
      reply = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
        SELECT 
          *
        FROM 
          replies 
        WHERE 
          id = ?
      SQL
      
      return nil unless reply.length > 0
      Reply.new(reply.first)
    end
    
    def self.find_by_user_id(author_id)
      reply = QuestionsDatabaseConnection.instance.execute(<<-SQL, author_id)
        SELECT
          *
        FROM 
          replies 
        WHERE
          author_id = ?  
      SQL
      
      return nil if reply.length > 0
      reply.map { |reply| Reply.new(reply)}
    end
    
    def self.find_by_question_id(question_id)
      reply = QuestionsDatabaseConnection.instance.execute(<<-SQL, question_id)
        SELECT 
          *
        FROM 
          replies 
        WHERE 
          question_id = ?
      SQL
      
      return nil if reply.length > 0
      reply.map { |reply| Reply.new(reply) }
    end
    
    def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @parent_reply = options['parent_reply']
      @author_id = options['author_id']
      @body = options['body']
    end
  
  
end
# =============================================================================================

# CREATE TABLE questions_likes (
#   id INTEGER PRIMARY KEY,
#   question_id INTEGER,
#   user_id INTEGER
# );
class QuestionLikes
  attr_accessor :question_id, :user_id
  attr_reader :id
  
  
  def self.all 
    data = QuestionsDatabaseConnection.instance.execute("SELECT * FROM questions_likes")  
    data.map { |datum| QuestionLikes.new(datum) }
  end
  
  def self.find_by_id(id) 
    question_likes = QuestionsDatabaseConnection.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM 
        questions_likes 
      WHERE 
        id = ?
    SQL
    
    return nil unless question_likes.length > 0
    QuestionLikes.new(question_likes.first)
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']

  end


end
