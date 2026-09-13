const express = require("express");
const router = express.Router();
const db = require("../config/db");
const jwt = require("jsonwebtoken");


router.post("/register", async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log("Register request received for email:", email);

  
    const [existingUsers] = await db.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(400).json({
        message: "Email is already registered"
      });
    }

    const generatedUsername = email.split('@')[0];

    await db.query(
      "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
      [generatedUsername, email, password]
    );

    res.status(201).json({
      message: "User registered successfully"
    });

  } catch (error) {
    console.error("Register Error:", error);
    res.status(500).json({
      message: "Server error during registration"
    });
  }
});



router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const [users] = await db.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        message: "Email not found"
      });
    }


router.post("/google", async (req, res) => {
  try {
    const { token } = req.body; 

    if (!token) {
      return res.status(400).json({ message: "Google Token is required" });
    }

    console.log("🔄 Backend menerima Google Token dari Flutter...");

   
    const decodedToken = jwt.decode(token);
    
  
    const emailGoogle = decodedToken?.email || "user.google@gmail.com";
    console.log("✅ Email dari Google Token:", emailGoogle);

    let [users] = await db.query("SELECT * FROM users WHERE email = ?", [emailGoogle]);
    let user;

    if (users.length === 0) {
      console.log("🔄 Akun Google belum terdaftar di DB, otomatis mendaftarkan...");
      const generatedUsername = emailGoogle.split('@')[0];
      const randomPassword = Math.random().toString(36).slice(-8); 

      const [result] = await db.query(
        "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
        [generatedUsername, emailGoogle, randomPassword]
      );

      const [newUsers] = await db.query("SELECT * FROM users WHERE id = ?", [result.insertId]);
      user = newUsers[0];
    } else {
      user = users[0];
    }

    const userRole = user.email === 'admin@gmail.com' ? 'admin' : 'user';

    const backendToken = jwt.sign(
      { id: user.id, email: user.email, role: userRole },
      process.env.JWT_SECRET || "default_secret_key_20_chars_long",
      { expiresIn: "30d" }
    );

    res.status(200).json({
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
    console.error("🚨 Google Auth Error:", error);
    res.status(500).json({ message: "Server error during Google Authentication" });
  }
});

    const user = users[0];

    if (user.password !== password) {
      return res.status(401).json({
        message: "Wrong password"
      });
    }

    const userRole = user.email === 'admin@gmail.com' ? 'admin' : 'user';

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: userRole 
      },
      process.env.JWT_SECRET || "default_secret_key_20_chars_long",
       {
         expiresIn: "30d"
       }
    );

    res.json({
      message: "Login successful",
      token,
      user: {
        id: user.id,
        email: user.email,
        role: userRole 
      }
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: "Server error"
    });
  }
});

module.exports = router;