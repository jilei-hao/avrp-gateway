
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

const secreteKey = process.env.SECRET_KEY;

function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  jwt.verify(token, secreteKey, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }

    console.log("[authenticateToken] user: ", user);

    req.user = user;
    next();
  });
}

export default authenticateToken;
