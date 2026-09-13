const mysql = require("mysql2/promise");


const pool = mysql.createPool({
  host: "localhost",
  user: "root",         
  password: "",       
  database: "genshin_import", 
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

console.log(" Kumpulan Koneksi MySQL Berhasil Dibuat!");

module.exports = pool;