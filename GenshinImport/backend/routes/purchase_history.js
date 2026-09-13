const express = require("express");
const router = express.Router();
const db = require("../config/db");
const authMiddleware = require("../middleware/authMiddleware");


router.post("/", authMiddleware, async (req, res) => {
  try {
    const id = parseInt(req.body.id);
    const quantity = parseInt(req.body.quantity);

    console.log("🔄 Menerima request beli produk ID:", id, "Sebanyak:", quantity);

    if (isNaN(id) || isNaN(quantity)) {
      return res.status(400).json({ message: "ID Produk atau Quantity tidak valid!" });
    }

    const [products] = await db.query("SELECT stock FROM products WHERE id = ?", [id]);
    
    if (products.length === 0) {
      return res.status(404).json({ message: "Produk tidak ditemukan di database!" });
    }

    const currentStock = products[0].stock;
    console.log("📊 Stok saat ini di DB:", currentStock, "| Jumlah diminta:", quantity);

    if (currentStock < quantity) {
      return res.status(400).json({ message: "Stok tidak mencukupi untuk dibeli!" });
    }

    await db.query(
      "INSERT INTO purchase_history (product_id, user_id, quantity) VALUES (?, ?, ?)",
      [id, req.user.id, quantity]
    );

    await db.query(
      "UPDATE products SET stock = stock - ? WHERE id = ?",
      [quantity, id]
    );

    res.status(201).json({ message: "Pembelian berhasil disimpan!" });
  } catch (error) {
    console.error("🚨 Error saat menyimpan pembelian:", error);
    res.status(500).json({ message: "Gagal menyimpan data pembelian" });
  }
});

router.get("/", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.id;

    const [rows] = await db.query(
      `
      SELECT
        purchase_history.id,
        products.name,
        products.price,
        purchase_history.quantity
      FROM purchase_history
      JOIN products ON purchase_history.product_id = products.id
      WHERE purchase_history.user_id = ?
      ORDER BY purchase_history.id DESC
      `,
      [user_id]
    );

    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Database error" });
  }
});

module.exports = router;