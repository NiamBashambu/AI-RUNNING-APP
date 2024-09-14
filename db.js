
//currently not in use
//needed for when using mongoDB


const mongoose = require('mongoose');

const mongoURI = 'mongodb://localhost:27017/strava';  // Replace with MongoDB URI
mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Define a schema for storing Strava tokens
const tokenSchema = new mongoose.Schema({
  athlete_id: {
    type: Number,
    required: true,
    unique: true,
  },
  access_token: {
    type: String,
    required: true,
  },
  refresh_token: {
    type: String,
    required: true,
  },
  expires_at: {
    type: Number,  // Storing as Unix timestamp (seconds)
    required: true,
  },
});

// Create a model from the schema
const Token = mongoose.model('Token', tokenSchema);

module.exports = Token;
