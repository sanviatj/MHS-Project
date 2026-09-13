const express = require("express");
const cors = require("cors");
const path = require("path");
const app = express();
require('dotenv').config();
const port = 3000;


app.use(cors()); 
app.use(express.json()); 
app.use(express.urlencoded({ extended: true }));

app.use("/images", express.static(path.join(__dirname, "public/images")));

app.get("/", (req, res) => {
  res.send("Genshin Import Backend API is running successfully!");
});

app.post("/users/google", async (req, res) => {
  try {
    const { token } = req.body;
    console.log("🔥 SAKTI: server.js sukses menangkap token Google:", token ? "Token Tersedia" : "Token Kosong");

    if (!token) {
      return res.status(400).json({ message: "Google Token is required" });
    }

    const jwt = require("jsonwebtoken");
    const decodedToken = jwt.decode(token);
    
    const emailGoogle = decodedToken?.email || "user.google@gmail.com";
    console.log("📧 Email Google terdeteksi:", emailGoogle);

    const db = require("./config/db");
    let [users] = await db.query("SELECT * FROM users WHERE email = ?", [emailGoogle]);
    let user;

    if (users.length === 0) {
      console.log("👤 Akun baru! Otomatis mendaftarkan ke database MySQL...");
      const generatedUsername = emailGoogle.split('@')[0];
      const randomPassword = Math.random().toString(36).slice(-8); 

      const [result] = await db.query(
        "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
        [generatedUsername, emailGoogle, randomPassword]
      );

      const [newUsers] = await db.query("SELECT * FROM users WHERE id = ?", [result.insertId]);
      user = newUsers[0];
    } else {
      console.log("🔄 User lama terdeteksi! Mempersiapkan sesi login...");
      user = users[0];
    }

    const userRole = user.email === 'admin@gmail.com' ? 'admin' : 'user';

    const backendToken = jwt.sign(
      { id: user.id, email: user.email, role: userRole },
      process.env.JWT_SECRET || "default_secret_key_20_chars_long",
      { expiresIn: "30d" }
    );

    return res.status(200).json({
      message: "Google login successful",
      token: backendToken,
      role: userRole,
      user: {
        id: user.id,
        email: user.email,
        role: userRole
      }
    });

  } catch (error) {
    console.error("🚨 DETAIL EROR UTAMA:", error.message || error);
    return res.status(500).json({ 
      message: "Server error during Google Authentication",
      error: error.message 
    });
  }
});

app.use("/users", require("./routes/auth")); 

app.use("/products", require("./routes/products")); 

app.use("/purchase_history", require("./routes/purchase_history"));

app.listen(port, () => {
  console.log(`==================================================`);
  console.log(` Server Genshin Import Aktif di http://localhost:${port}`);
  console.log(`==================================================`);
});