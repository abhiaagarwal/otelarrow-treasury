use color_eyre::Result;
use duckdb::Connection;

const SCHEMA: &str = include_str!("../schema.sql");

pub struct Database {
    conn: Connection,
}

impl Database {
    pub fn new() -> Result<Database> {
        todo!()
    }

    pub fn create_tables(&mut self) -> Result<()> {
        let conn = &self.conn;
        conn.execute_batch(format!("BEGIN {} END", SCHEMA).as_str())?;
        todo!()
    }
}
