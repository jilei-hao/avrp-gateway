import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import express from 'express';
import { DBHelper } from '../util/db-helper.js';

dotenv.config({ path: '.env.local' });

const secretKey = process.env.SECRET_KEY;
const router = express.Router();
const db = DBHelper.getInstance();

router.use(express.json());

router.post('/', async (req, res) => {
  try {
    let { username, password } = req.body;

    if (username == null || password == null) {
      // try again using the authentication header (in the future it should be the only way to authenticate)
      const authHeader = req.headers.authorization;
      if (authHeader) {
        const auth = Buffer.from(authHeader.split(' ')[1], 'base64').toString('utf8');
        username = auth.split(':')[0];
        password = auth.split(':')[1];
      }
    }

    console.log("[loginRoutes::post] request body", req.body);

    const query = 'SELECT * FROM fn_get_user_info($1)';
    const result = await db.query(query, [username]);

    if (result.rowCount !== 0) {
      const row = result[0];
      const dbPWHash = row['password_hash'];

      console.log("[loginRoute::post] dbPWHash: ", dbPWHash);

      const isPasswordValid = await bcrypt.compare(password, dbPWHash);

      if (!isPasswordValid) {
        res.status(401).json({ 
          success: false, 
          token: '',
          error: "Invalid credentials!"
        });
        return;
      }

      const userId = row['user_id'];

      res.status(200).json({
        success: true,
        token: jwt.sign({ userId: userId }, secretKey, { expiresIn: '24h' }),
        error: ''
      });
    } else {
      res.status(401).json({ 
        success: false, 
        token: '',
        error: "User not found!"
      });
    }
  } catch (error) {
    console.error('Error processing the request:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
