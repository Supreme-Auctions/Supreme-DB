-- Create users table for user management
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  firebase_uid TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'lister', 'user')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view all users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert users" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update users" ON users FOR UPDATE USING (true);
CREATE POLICY "Users can delete users" ON users FOR DELETE USING (true);

-- Insert a sample admin user (you can modify this with your actual admin email)
-- Note: You'll need to update this with the actual Firebase UID after creating the admin user
-- Roles: 'admin' (full access), 'lister' (add/edit stock), 'user' (view only)
-- INSERT INTO users (firebase_uid, email, display_name, role, status) 
-- VALUES ('YOUR_FIREBASE_UID_HERE', 'admin@example.com', 'Admin User', 'admin', 'active');

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at 
  BEFORE UPDATE ON users 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT ALL ON users TO authenticated;
GRANT ALL ON users TO anon; 