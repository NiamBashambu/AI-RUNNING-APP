const express = require('express');
const axios = require('axios');
require('dotenv').config();
const fs = require('fs');

const app = express();
const port = 1000;

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

// Handle OAuth callback and exchange code for tokens
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

    // Save activities to a file
    const filePath = './activities.json';
    fs.writeFile(filePath, JSON.stringify(activities, null, 2), (err) => {
      if (err) {
        console.error('Error writing activities to file:', err);
        return res.status(500).send('Failed to write activities to file');
      }
      console.log(`Activities saved to ${filePath}`);
    });

    // Send the activities as a response
    res.json(activities);

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
