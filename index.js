const express = require('express');
const axios = require('axios');
require('dotenv').config();
const { exec } = require('child_process');
const cors = require('cors'); // Import CORS



const app = express();
const port = 2000;
const fs = require('fs');

// Middleware to parse JSON responses
app.use(express.json());
app.use(cors())

// In-memory storage for tokens (for demonstration purposes)
// In production, use a database
let accessToken = '75663b5ed6ce3fb00639894332822b15ad2b61c2';
let refreshToken = 'cdec0b698f2012ec7db768e2a463de3a236504fc';
let expiresAt = 'expires at: 2024-09-29T01:18:34Z';

// Redirect user to Strava's OAuth page
app.get('/auth/strava', (req, res) => {
  const params = new URLSearchParams({
    client_id: process.env.CLIENT_ID,
    redirect_uri: process.env.REDIRECT_URI,
    response_type: 'code',
    scope: 'read,activity:read_all',
  });
  console.log('Received request for activities');

  res.redirect(`https://www.strava.com/oauth/mobile/authorize?${params.toString()}`);
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

    console.log('Tokens received, redirecting to activities');
    res.redirect('/activities');
  } catch (error) {
    console.error('Error exchanging code for token:', error.response.data);
    res.status(500).send('Authentication failed');
  }
});

// Middleware to refresh the access token if expired
const refreshAccessTokenIfNeeded = async () => {
  const currentTime = Math.floor(Date.now() / 1000); // Get current time in seconds

  if (!accessToken || expiresAt <= currentTime) {
    console.log('Access token expired or not set, refreshing...');
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

      console.log('Access token refreshed:', accessToken);
    } catch (error) {
      console.error('Error refreshing access token:', error.response.data);
      throw new Error('Could not refresh access token.');
    }
  }
};

// Fetch and display user activities
app.get('/activities', async (req, res) => {
  try {
      await refreshAccessTokenIfNeeded();
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
          console.error('Python script stderr:', stderr); // Log stderr to see errors
          return res.status(500).send('Python script error');
      }
  
      console.log('Python script output:', stdout);
  
      // Parse stdout to get recommendations
      let recommendations;
      try {
          recommendations = JSON.parse(stdout);
      } catch (parseError) {
        console.error('Error parsing recommendations:', parseError);
        console.error('Raw output:', stdout); // Log the raw output for debugging
        return res.status(500).send('Failed to parse recommendations');
    }
  
      // Send only recommendations as response
      res.json({ recommendations });
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


