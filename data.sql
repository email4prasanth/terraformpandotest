-- Create the tables

-- Table: categories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(150),
    remarks VARCHAR(500)
);

-- Insert data into categories
INSERT INTO categories (category_name, remarks) VALUES
('Comedy', 'Movies with humour'),
('Romantic', 'Love stories'),
('Epic', 'Story ancient movies'),
('Horror', NULL),
('Science Fiction', NULL),
('Thriller', NULL),
('Action', NULL),
('Romantic Comedy', NULL);




-- Table: movies
CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(300),
    director VARCHAR(150),
    year_released INTEGER,
    category_id INTEGER,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Insert data into movies
INSERT INTO movies (title, director, year_released, category_id) VALUES
('Pirates of the Caribean 4', 'Rob Marshall', 2011, 1),
('Forgetting Sarah Marshal', 'Nicholas Stoller', 2008, 2),
('X-Men', NULL, 2008, NULL),
('Code Name Black', 'Edgar Jimz', 2010, NULL),
('Daddy\'s Little Girls', NULL, 2007, 8),
('Angels and Demons', NULL, 2007, 6),
('Davinci Code', NULL, 2007, 6),
('Honey mooners', 'John Schultz', 2005, 8),
('67% Guilty', NULL, 2012, NULL);

-- Table: members
CREATE TABLE members (
    membership_number SERIAL PRIMARY KEY,
    full_names VARCHAR(350) NOT NULL,
    gender VARCHAR(6),
    date_of_birth DATE,
    physical_address VARCHAR(255),
    postal_address VARCHAR(255),
    contact_number VARCHAR(75),
    email VARCHAR(255)
);

-- Insert data into members
INSERT INTO members (full_names, gender, date_of_birth, physical_address, postal_address, contact_number, email) VALUES
('Janet Jones', 'Female', '1980-07-21', 'First Street Plot No 4', 'Private Bag', '0759 253 542', 'janetjones@yagoo.cm'),
('Janet Smith Jones', 'Female', '1980-06-23', 'Melrose 123', NULL, NULL, 'jj@fstreet.com'),
('Robert Phil', 'Male', '1989-07-12', '3rd Street 34', NULL, '12345', 'rm@tstreet.com'),
('Gloria Williams', 'Female', '1984-02-14', '2nd Street 23', NULL, NULL, NULL);

-- Table: payments
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    membership_number INTEGER,
    payment_date DATE,
    description VARCHAR(75),
    amount_paid FLOAT,
    external_reference_number INTEGER,
    FOREIGN KEY (membership_number) REFERENCES members(membership_number)
);

-- Insert data into payments
INSERT INTO payments (membership_number, payment_date, description, amount_paid, external_reference_number) VALUES
(1, '2012-07-23', 'Movie rental payment', 2500, 11),
(1, '2012-07-25', 'Movie rental payment', 2000, 12),
(3, '2012-07-30', 'Movie rental payment', 6000, NULL);

-- Table: movierentals
CREATE TABLE movierentals (
    reference_number SERIAL PRIMARY KEY,
    transaction_date DATE,
    return_date DATE,
    membership_number INTEGER,
    movie_id INTEGER,
    movie_returned BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (membership_number) REFERENCES members(membership_number),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- Insert data into movierentals
INSERT INTO movierentals (transaction_date, return_date, membership_number, movie_id, movie_returned) VALUES
('2012-06-20', NULL, 1, 1, FALSE),
('2012-06-22', '2012-06-25', 1, 2, FALSE),
('2012-06-22', '2012-06-25', 3, 2, FALSE),
('2012-06-21', '2012-06-24', 2, 2, FALSE),
('2012-06-23', NULL, 3, 3, FALSE);

-- Create the views

-- View: accounts_v_members
CREATE VIEW accounts_v_members AS
SELECT 
    membership_number,
    full_names,
    gender
FROM members;

-- View: general_v_movie_rentals
CREATE VIEW general_v_movie_rentals AS
SELECT 
    mb.membership_number,
    mb.full_names,
    mo.title,
    mr.transaction_date,
    mr.return_date
FROM 
    movierentals mr
JOIN 
    members mb ON mr.membership_number = mb.membership_number
JOIN 
    movies mo ON mr.movie_id = mo.movie_id;


INSERT INTO "categories" ("category_name", "remarks") VALUES
    ('Comedy1', 'Movies with humor'),
    ('Romantic1', 'Love stories');

INSERT INTO movies (title, director, year_released, category_id) VALUES
('Pirates of the Caribean 5', 'Rob Marshall', 2011, 1),
('Forgetting Sarah Marshal 2', 'Nicholas Stoller', 2008, 2);