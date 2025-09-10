// External dependencies
const express = require('express');

const router = express.Router();

// Add your routes here - above the module.exports line

// My BP Accessibility Settings Routes
router.get('/pages/mybp/accessibility-settings/', function (req, res) {
  res.render('pages/mybp/accessibility-settings/index');
});

router.post('/pages/mybp/accessibility-settings/', function (req, res) {
  // Save the settings to session data
  const data = req.session.data || {};
  
  // Save each setting
  data['large-text'] = req.body['large-text'];
  data['high-contrast'] = req.body['high-contrast'];
  data['voice-readback'] = req.body['voice-readback'];
  data['language'] = req.body['language'];
  data['bsl-videos'] = req.body['bsl-videos'];
  data['easy-read'] = req.body['easy-read'];
  
  req.session.data = data;
  
  // Redirect to confirmation page
  res.redirect('/pages/mybp/accessibility-settings/confirmation');
});

router.get('/pages/mybp/accessibility-settings/confirmation', function (req, res) {
  res.render('pages/mybp/accessibility-settings/confirmation');
});

router.get('/pages/mybp/accessibility-settings/reset', function (req, res) {
  // Reset all accessibility settings
  const data = req.session.data || {};
  
  data['large-text'] = '';
  data['high-contrast'] = '';
  data['voice-readback'] = '';
  data['language'] = 'en';
  data['bsl-videos'] = '';
  data['easy-read'] = '';
  
  req.session.data = data;
  
  // Redirect back to settings page
  res.redirect('/pages/mybp/accessibility-settings/');
});

module.exports = router;
