-- Create categories table for category management
CREATE TABLE IF NOT EXISTS categories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name);

-- Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Create policies for categories table
CREATE POLICY "Categories can be viewed by all authenticated users" ON categories FOR SELECT USING (true);
CREATE POLICY "Categories can be inserted by authenticated users" ON categories FOR INSERT WITH CHECK (true);
CREATE POLICY "Categories can be updated by authenticated users" ON categories FOR UPDATE USING (true);
CREATE POLICY "Categories can be deleted by authenticated users" ON categories FOR DELETE USING (true);

-- Insert some default categories
INSERT INTO categories (name) VALUES 
('Electronics'),
('Clothing'),
('Books'),
('Home & Garden'),
('Sports'),
('Toys'),
('Health & Beauty'),
('Automotive')
ON CONFLICT (name) DO NOTHING;

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_categories_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_categories_updated_at 
  BEFORE UPDATE ON categories 
  FOR EACH ROW 
  EXECUTE FUNCTION update_categories_updated_at_column();

-- Grant necessary permissions
GRANT ALL ON categories TO authenticated;
GRANT ALL ON categories TO anon; 