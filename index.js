const express = require('express');
const axios = require('axios');
require('dotenv').config();
const { exec } = require('child_process');


const app = express();
const port = 1000;
const fs = require('fs');

// Middleware to parse JSON responses
app.use(express.json());

// In-memory storage for tokens (for demonstration purposes)
// In production, use a database
let accessToken = '54f01bbb30e750c69fcfcb3eea05550b3fb31bd7';
let refreshToken = 'cdec0b698f2012ec7db768e2a463de3a236504fc';
let expiresAt = '2024-09-15T02:19:04Z';

// Redirect user to Strava's OAuth page
app.get('/auth/strava', (req, res) => {
  const params = new URLSearchParams({
    client_id: process.env.CLIENT_ID,
    redirect_uri: process.env.REDIRECT_URI,
    response_type: 'code',
    scope: 'read,activity:read_all',
  });

  res.redirect(`https://www.strava.com/oauth/authorize?${params.toString()}`);
});

//  Handle OAuth callback and exchange code for tokens
app.get('/auth/callback', async (req, res) => {
  const { code } = req.query;

  try {
    const response = await axios.post('https://www.strava.com/oauth/token', null, {
      params: {
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        code,
        grant_type: 'authorization_code',
      },
    });

    accessToken = response.data.access_token;
    refreshToken = response.data.refresh_token;
    expiresAt = response.data.expires_at;

    res.redirect('/activities');
  } catch (error) {
    console.error('Error exchanging code for token:', error.response.data);
    res.status(500).send('Authentication failed');
  }
});

// Middleware to refresh the access token if expired
app.use(async (req, res, next) => {
  if (!accessToken) {
    return res.redirect('/auth/strava');
  }

  const currentTime = Math.floor(Date.now() / 1000);

  if (expiresAt <= currentTime) {
    try {
      const response = await axios.post('https://www.strava.com/oauth/token', null, {
        params: {
          client_id: process.env.CLIENT_ID,
          client_secret: process.env.CLIENT_SECRET,
          grant_type: 'refresh_token',
          refresh_token: refreshToken,
        },
      });

      accessToken = response.data.access_token;
      refreshToken = response.data.refresh_token;
      expiresAt = response.data.expires_at;

      console.log('Access token refreshed');
    } catch (error) {
      console.error('Error refreshing access token:', error.response.data);
      return res.redirect('/auth/strava');
    }
  }

  next();
});

// Fetch and display user activities
app.get('/activities', async (req, res) => {
  try {
    const response = await axios.get('https://www.strava.com/api/v3/athlete/activities', {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    const activities = response.data;


    const activitiesJson = JSON.stringify(activities);

    // Call the Python script with the activities data
    exec(`python3 recommendations.py '${activitiesJson}'`, (error, stdout, stderr) => {
      if (error) {
        console.error('Error executing Python script:', error.message);
        return res.status(500).send('Failed to process activities with Python script');
      }

      if (stderr) {
        console.error('Python script stderr:', stderr);
        return res.status(500).send('Python script error');
      }

      console.log('Python script output:', stdout);

      // Send the output of the Python script as the response
      res.json({ message: 'Activities processed', result: stdout });
    });
  
  } catch (error) {
    console.error('Error fetching activities:', error.response.data);
    res.status(500).send('Failed to fetch activities');
  }
  
});


// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log(`Authorize the app by visiting http://localhost:${port}/auth/strava`);
});


//need to update this with the mongo db database when that happens
//something like below
/*
const express = require('express');
const axios = require('axios');
const Token = require('./db');  // Import the MongoDB Token model
require('dotenv').config();

const app = express();
const port = 3000;

// Redirect to Strava's OAuth authorization page
app.get('/login', (req, res) => {
  const stravaAuthUrl = `https://www.strava.com/oauth/authorize?client_id=${process.env.CLIENT_ID}&redirect_uri=${process.env.REDIRECT_URI}&response_type=code&scope=read,activity:read_all`;
  res.redirect(stravaAuthUrl);
});

// Handle OAuth redirect and get access token
app.get('/redirect', async (req, res) => {
  const authorizationCode = req.query.code;

  try {
    const tokenResponse = await axios.post('https://www.strava.com/oauth/token', {
      client_id: process.env.CLIENT_ID,
      client_secret: process.env.CLIENT_SECRET,
      code: authorizationCode,
      grant_type: 'authorization_code',
    });

    const { access_token, refresh_token, expires_at, athlete } = tokenResponse.data;

    // Upsert token data into MongoDB
    await Token.findOneAndUpdate(
      { athlete_id: athlete.id },
      { access_token, refresh_token, expires_at },
      { upsert: true, new: true }
    );

    res.send('Authentication successful. You can now fetch activities.');
  } catch (error) {
    console.error('Error retrieving access token:', error);
    res.status(500).send('Error retrieving Strava access token.');
  }
});

// Helper function to refresh expired tokens
const refreshAccessToken = async (athlete_id) => {
  const token = await Token.findOne({ athlete_id });

  if (!token) {
    throw new Error('Athlete not found in the database.');
  }

  const currentTime = Math.floor(Date.now() / 1000);  // Get current time in seconds

  // If the token is expired, refresh it
  if (token.expires_at < currentTime) {
    try {
      const refreshResponse = await axios.post('https://www.strava.com/oauth/token', {
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        grant_type: 'refresh_token',
        refresh_token: token.refresh_token,
      });

      const { access_token, refresh_token, expires_at } = refreshResponse.data;

      // Update the token in the database
      await Token.findOneAndUpdate(
        { athlete_id },
        { access_token, refresh_token, expires_at },
        { new: true }
      );

      return access_token;
    } catch (error) {
      throw new Error('Error refreshing Strava access token.');
    }
  } else {
    return token.access_token;  // Token is still valid
  }
};

//  Fetch user activities, refreshing token if needed
app.get('/activities', async (req, res) => {
  const athlete_id = req.query.athlete_id;

  try {
    const access_token = await refreshAccessToken(athlete_id);

    const activitiesResponse = await axios.get('https://www.strava.com/api/v3/athlete/activities', {
      headers: {
        Authorization: `Bearer ${access_token}`,
      },
    });

    res.json(activitiesResponse.data);
  } catch (error) {
    console.error('Error fetching activities:', error);
    res.status(500).send('Error fetching activities from Strava.');
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
    
*/