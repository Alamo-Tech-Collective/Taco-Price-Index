class AddUserForeignKeyToReviews < ActiveRecord::Migration[8.0]
  def up
    # Ensure the user_id column is nullable
    change_column_null :reviews, :user_id, true

    # Add index if it doesn't exist
    unless index_exists?(:reviews, :user_id)
      add_index :reviews, :user_id
    end

    # Instead of a foreign key, we'll add a check constraint that verifies
    # the user_id exists in the users table. This is a weaker guarantee than
    # a foreign key but works across different data types.
    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_user_exists()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NEW.user_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.user_id::bigint) THEN
          RAISE EXCEPTION 'User with id % does not exist', NEW.user_id;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      DROP TRIGGER IF EXISTS check_user_trigger ON reviews;
      CREATE TRIGGER check_user_trigger
      BEFORE INSERT OR UPDATE ON reviews
      FOR EACH ROW
      EXECUTE FUNCTION check_user_exists();
    SQL
  end

  def down
    # Remove the trigger and function
    execute <<-SQL
      DROP TRIGGER IF EXISTS check_user_trigger ON reviews;
      DROP FUNCTION IF EXISTS check_user_exists();
    SQL

    # Remove the index if it exists
    remove_index :reviews, :user_id if index_exists?(:reviews, :user_id)
  end
end
