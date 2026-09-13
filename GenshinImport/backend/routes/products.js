const express = require("express");
const router = express.Router();
const db = require("../config/db");
const authMiddleware = require("../middleware/authMiddleware");
const path = require("path");
const multer = require("multer"); 

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "public/images"); 
  },
  filename: (req, file, cb) => {
    cb(null, file.originalname); 
  }
});

const upload = multer({ storage: storage });


router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM products");
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Database error" });
  }
});


router.post(
  "/",
  authMiddleware,
  upload.single('image'), 
  async (req, res) => {
    try {
      const { name, type, description, stock, price } = req.body;

      const imageName = req.file ? req.file.originalname : req.body.image;

      const [result] = await db.query(
        `INSERT INTO products 
        (name, type, description, stock, image, price) 
        VALUES (?, ?, ?, ?, ?, ?)`,
        [name, type, description, stock, imageName, price]
      );

      res.status(201).json({
        message: "Product created",
        id: result.insertId
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Database error" });
    }
  }
);

router.put(
  "/:id",
  authMiddleware,
  upload.single('image'), 
  async (req, res) => {
    try {
      const { id } = req.params;
      const { name, type, description, stock, price } = req.body;

    
      const imageName = req.file ? req.file.originalname : req.body.image;

      await db.query(
        `UPDATE products 
         SET name=?, type=?, description=?, stock=?, image=?, price=? 
         WHERE id=?`,
        [name, type, description, stock, imageName, price, id]
      );

      res.json({ message: "Product updated" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: "Database error" });
    }
  }
);

router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    await db.query("DELETE FROM products WHERE id = ?", [id]);
    res.json({ message: "Product deleted" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Database error" });
  }
});

module.exports = router;