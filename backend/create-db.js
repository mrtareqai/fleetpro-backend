const mysql = require('mysql2/promise');
async function createDB() {
  try {
    const connection = await mysql.createConnection({ host: '127.0.0.1', user: 'root', password: '' });
    await connection.query('CREATE DATABASE IF NOT EXISTS fleetpro_db;');
    console.log('Database fleetpro_db created or already exists');
    await connection.end();
  } catch (err) {
    console.error('Error creating database:', err);
    process.exit(1);
  }
}
createDB();
