const path = require('path');
const dotenv = require('dotenv');

// 🔥 Load explicitly from the absolute path
dotenv.config({ path: path.resolve(__dirname, '.env') });

console.log('✅ Testing .env Loading...');
console.log('PORT:', process.env.PORT);
console.log('MONGO_URI:', process.env.MONGO_URI);
console.log('JWT_SECRET:', process.env.JWT_SECRET);
