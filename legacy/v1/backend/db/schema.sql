-- Users
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Households
CREATE TABLE IF NOT EXISTS households (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Memberships
CREATE TABLE IF NOT EXISTS household_members (
  id SERIAL PRIMARY KEY,
  household_id INT REFERENCES households(id),
  user_id INT REFERENCES users(id),
  role TEXT DEFAULT 'member'
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  household_id INT REFERENCES households(id),
  name TEXT NOT NULL,
  color TEXT
);

-- Budgets
CREATE TABLE IF NOT EXISTS budgets (
  id SERIAL PRIMARY KEY,
  household_id INT REFERENCES households(id),
  category_id INT REFERENCES categories(id),
  amount NUMERIC(12,2) NOT NULL,
  month TEXT NOT NULL
);

-- Expenses
CREATE TABLE IF NOT EXISTS expenses (
  id SERIAL PRIMARY KEY,
  household_id INT REFERENCES households(id),
  category_id INT REFERENCES categories(id),
  amount NUMERIC(12,2) NOT NULL,
  note TEXT,
  spent_at DATE NOT NULL
);

-- Shopping List
CREATE TABLE IF NOT EXISTS shopping_items (
  id SERIAL PRIMARY KEY,
  household_id INT REFERENCES households(id),
  name TEXT NOT NULL,
  category TEXT,
  done BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
