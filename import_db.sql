DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions_likes;

PRAGMA foreign_keys = ON;

CREATE TABLE users (
  fname TEXT NOT NULL,
  lname TEXT NOT NULL,
  id INTEGER PRIMARY KEY

);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL, 
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);


CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  follower_id INTEGER,
  question_id INTEGER,
  
  FOREIGN KEY (follower_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,  --will reference questions table using questions_id
  parent_reply INTEGER, --type replies.id
  author_id INTEGER NOT NULL, -- reference users.id
  body TEXT NOT NULL
);

CREATE TABLE questions_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  user_id INTEGER
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Kat', 'Peters'),
  ('Christine', 'Pham'),
  ('Dave', 'Pham'),
  ('Bob', 'Pham'),
  ('Jane', 'Pham');
  
  
INSERT INTO --title body author
  questions(title, body, author_id)
VALUES
  ('Question1', 'What are clouds?', (SELECT id FROM users WHERE fname = 'Kat')),
  ('Question2', 'What are cats?', (SELECT id FROM users WHERE fname = 'Christine')),
  ('Question3', 'What is your favorite color?', (SELECT id FROM users WHERE fname = 'Bob')),
  ('Question4', 'Why make your bed?', (SELECT id FROM users WHERE fname = 'Dave')),
  ('Question5', 'ninjas or pirates?', (SELECT id FROM users WHERE fname = 'Christine'));
  
  
INSERT INTO
  question_follows(follower_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Christine'), (SELECT id FROM questions WHERE title = 'Question1')),
  ((SELECT id FROM users WHERE fname = 'Dave'), (SELECT id FROM questions WHERE title = 'Question1')),
  ((SELECT id FROM users WHERE fname = 'Bob'), (SELECT id FROM questions WHERE title = 'Question2')),
  ((SELECT id FROM users WHERE fname = 'Jane'), (SELECT id FROM questions WHERE title = 'Question5')),
  ((SELECT id FROM users WHERE fname = 'Dave'), (SELECT id FROM questions WHERE title = 'Question5')),
  ((SELECT id FROM users WHERE fname = 'Kat'), (SELECT id FROM questions WHERE title = 'Question5'));
  
  
INSERT INTO
  replies(question_id, parent_reply, author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Question1'), NULL, (SELECT id FROM users WHERE fname = 'Christine'), "I think they are water.");

INSERT INTO
  replies(question_id, parent_reply, author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Question1'), (SELECT id FROM replies WHERE body = "I think they are water."), 
(SELECT id FROM users WHERE fname = 'Bob'), "I think so too!");

INSERT INTO
  questions_likes (question_id, user_id)
VALUES 
  ((SELECT id FROM questions WHERE title = 'Question1'), (SELECT id FROM users WHERE fname = 'Christine')),
  ((SELECT id FROM questions WHERE title = 'Question1'), (SELECT id FROM users WHERE fname = 'Dave')),
  ((SELECT id FROM questions WHERE title = 'Question1'), (SELECT id FROM users WHERE fname = 'Bob'));