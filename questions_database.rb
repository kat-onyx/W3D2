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
  attr_accessor :title, :body, :author_id
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
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(1)
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def author
    User.find_by_id(self.author_id)
  end
  
  def replies
    Reply.find_by_question_id(self.id)
  end
  
  def followers
    QuestionFollow.followers_for_question_id(self.id)
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
  
  def authored_questions
    Question.find_by_author_id(self.id)  
  end
  
  def authored_replies
    Reply.find_by_user_id(self.id)
  end
  
  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
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
  
  def self.followers_for_question_id(question_id)
    user = QuestionsDatabaseConnection.instance.execute(<<-SQL, question_id)
      SELECT 
        *
      FROM 
        users
      JOIN question_follows 
        ON question_follows.follower_id = users.id 
      JOIN questions 
        ON questions.id = question_follows.question_id
      WHERE 
        question_id = ?
    SQL
    
    return nil unless user.length > 0
    user.map { |user| User.new(user) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    question = QuestionsDatabaseConnection.instance.execute(<<-SQL, user_id)
      SELECT 
        *
      FROM 
        questions
      JOIN question_follows 
        ON question_follows.question_id = questions.id
      JOIN users
        ON users.id = question_follows.follower_id
      WHERE 
        follower_id = ?
    SQL
    
    return nil unless question.length > 0
    question.map { |question| Question.new(question) }
  end
  
  def self.most_followed_questions(n)
    most_followed = QuestionsDatabaseConnection.instance.execute(<<-SQL, n)
      SELECT 
        *
      FROM 
        questions
      JOIN question_follows
        ON question_follows.question_id = questions.id
      GROUP BY question_id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    
    return nil unless most_followed.length > 0
    most_followed.map { |followed| Question.new(followed) }
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
      
      return nil unless reply.lengh > 0
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
      
      return nil unless reply.length > 0
      reply.map { |reply| Reply.new(reply) }
    end
    
    def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @parent_reply = options['parent_reply']
      @author_id = options['author_id']
      @body = options['body']
    end
  
    def author
      User.find_by_id(self.author_id)
    end
    
    def question
      Question.find_by_id(self.question_id)
    end
    
    def parent_reply
      Reply.find_by_id(self.parent_reply)
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
  
  def self.likers_for_question_id(question_id)
      users = QuestionsDatabaseConnection.instance.execute(<<-SQL, question_id)
        SELECT
          *
        FROM
          users
        JOIN 
          questions_likes ON questions_likes.user_id = users.id
        JOIN 
          questions ON questions.id = questions_likes.question_id
        WHERE
          questions.id = ?
      SQL
      return nil unless users.length > 0
      users.map{|user| User.new(user)}
  end
  
  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDatabaseConnection.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        questions_likes
      WHERE
        questions_likes.question_id = ?
      GROUP BY
        questions_likes.question_id

    SQL
     num_likes.first.values[0]
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
  
  

end
