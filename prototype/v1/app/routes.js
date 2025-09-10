// External dependencies
const express = require('express')

const router = express.Router()

// Add your routes here - above the module.exports line

// Dose Titration Journey Routes
router.get('/dose-titration', function (req, res) {
  res.render('dose-titration/index')
})

router.get('/dose-titration/review', function (req, res) {
  res.render('dose-titration/review')
})

router.post('/dose-titration/review', function (req, res) {
  res.redirect('/dose-titration/recommendation')
})

router.get('/dose-titration/recommendation', function (req, res) {
  res.render('dose-titration/recommendation')
})

router.post('/dose-titration/recommendation', function (req, res) {
  if (req.body.accept === 'yes') {
    res.redirect('/dose-titration/confirmation')
  } else {
    res.redirect('/dose-titration/declined')
  }
})

router.get('/dose-titration/confirmation', function (req, res) {
  res.render('dose-titration/confirmation')
})

router.get('/dose-titration/declined', function (req, res) {
  res.render('dose-titration/declined')
})

// BP Measurement Journey Routes
router.get('/bp-measurement', function (req, res) {
  res.render('bp-measurement/index')
})

router.get('/bp-measurement/locations', function (req, res) {
  res.render('bp-measurement/locations')
})

router.post('/bp-measurement/locations', function (req, res) {
  res.redirect('/bp-measurement/appointment')
})

router.get('/bp-measurement/appointment', function (req, res) {
  res.render('bp-measurement/appointment')
})

router.post('/bp-measurement/appointment', function (req, res) {
  res.redirect('/bp-measurement/confirmation')
})

router.get('/bp-measurement/confirmation', function (req, res) {
  res.render('bp-measurement/confirmation')
})

router.get('/bp-measurement/results', function (req, res) {
  res.render('bp-measurement/results')
})

// Blood Test Journey Routes
router.get('/blood-test', function (req, res) {
  res.render('blood-test/index')
})

router.get('/blood-test/information', function (req, res) {
  res.render('blood-test/information')
})

router.get('/blood-test/locations', function (req, res) {
  res.render('blood-test/locations')
})

router.post('/blood-test/locations', function (req, res) {
  res.redirect('/blood-test/appointment')
})

router.get('/blood-test/appointment', function (req, res) {
  res.render('blood-test/appointment')
})

router.post('/blood-test/appointment', function (req, res) {
  res.redirect('/blood-test/confirmation')
})

router.get('/blood-test/confirmation', function (req, res) {
  res.render('blood-test/confirmation')
})

module.exports = router
