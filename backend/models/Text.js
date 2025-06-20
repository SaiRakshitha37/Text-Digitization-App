// const mongoose = require('mongoose');

// const textSchema = new mongoose.Schema({
//   content: {
//     type: String,
//     required: true,
//   },
//   dateTime: {
//     type: Date,
//     default: Date.now,
//   },
//   user: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User',
//     required: true,
//   },
// });

// module.exports = mongoose.model('Text', textSchema);

const mongoose = require('mongoose');

const textSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  name: String,
  date: { type: Date, default: Date.now },
  createdAt: { type: Date, default: Date.now },
  isDeleted: { type: Boolean, default: false },
  deletedAt: { type: Date, default: null }
});

module.exports = mongoose.model('Text', textSchema);
