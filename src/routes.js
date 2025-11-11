/**
 * Routes Module
 * Defines all API endpoints and their handlers
 */

const express = require('express');
const db = require('./db');
const profanityFilter = require('./profanityFilter');
const { register, Counter, Histogram } = require('prom-client');

const router = express.Router();

// Prometheus metrics
const quotesServedCounter = new Counter({
  name: 'quotes_served_total',
  help: 'Total number of random quotes served'
});

const quotesAddedCounter = new Counter({
  name: 'quotes_added_total',
  help: 'Total number of quotes successfully added'
});

const profanityBlockedCounter = new Counter({
  name: 'profanity_blocked_total',
  help: 'Total number of quotes blocked due to profanity'
});

// New: HTTP request counter (method, route, status) and request duration histogram
const httpRequestsCounter = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests received',
  labelNames: ['method', 'route', 'status']
});

const requestDurationHistogram = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Histogram of HTTP request durations in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5]
});

// Middleware: observe every request (route-level)
router.use((req, res, next) => {
  // Use the raw path as the route label (includes queryless path)
  const routeLabel = req.route?.path || req.path || req.originalUrl || req.url;

  // Start timer for duration histogram with labels
  const endTimer = requestDurationHistogram.startTimer({ method: req.method, route: routeLabel });

  res.on('finish', () => {
    // Increment HTTP requests counter with status code
    httpRequestsCounter.inc({ method: req.method, route: routeLabel, status: String(res.statusCode) });
    // Stop the timer and record duration
    endTimer();
  });

  next();
});

/**
 * GET /quote
 * Returns a random quote from the database
 */
router.get('/quote', async (req, res) => {
  try {
    const quote = await db.getRandomQuote();
    
    if (!quote) {
      return res.status(404).json({
        success: false,
        error: 'No quotes found in database'
      });
    }
    
    // Increment Prometheus counter
    quotesServedCounter.inc();
    
    res.json({
      success: true,
      data: {
        id: quote.id,
        text: quote.text,
        author: quote.author,
        views: quote.views
      }
    });
  } catch (error) {
    console.error('Error fetching random quote:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quote',
      message: error.message
    });
  }
});

/**
 * POST /quote
 * Adds a new quote to the database
 * Body: { "text": "Quote text", "author": "Author name" }
 */
router.post('/quote', async (req, res) => {
  try {
    const { text, author } = req.body;
    
    // Validate required fields
    if (!text || !author) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: 'Both "text" and "author" fields are required'
      });
    }
    
    // Validate text and author are strings
    if (typeof text !== 'string' || typeof author !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: 'Both "text" and "author" must be strings'
      });
    }
    
    // Validate length
    if (text.trim().length === 0 || author.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: 'Both "text" and "author" cannot be empty'
      });
    }
    
    if (text.length > 1000) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: 'Quote text cannot exceed 1000 characters'
      });
    }
    
    if (author.length > 100) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: 'Author name cannot exceed 100 characters'
      });
    }
    
    // Check for profanity
    const validation = profanityFilter.validateQuote(text, author);
    if (!validation.isValid) {
      // Increment profanity blocked counter
      profanityBlockedCounter.inc();
      
      return res.status(400).json({
        success: false,
        error: 'Profanity detected',
        message: validation.message
      });
    }
    
    // Add quote to database
    const newQuote = await db.addQuote(text.trim(), author.trim());
    
    // Increment quotes added counter
    quotesAddedCounter.inc();
    
    res.status(201).json({
      success: true,
      message: 'Quote added successfully',
      data: {
        id: newQuote.id,
        text: newQuote.text,
        author: newQuote.author,
        views: newQuote.views
      }
    });
  } catch (error) {
    console.error('Error adding quote:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add quote',
      message: error.message
    });
  }
});

/**
 * GET /quotes
 * Returns all quotes ordered by creation date
 */
router.get('/quotes', async (req, res) => {
  try {
    const quotes = await db.getAllQuotes();
    res.json({
      success: true,
      data: quotes
    });
  } catch (error) {
    console.error('Error fetching quotes collection:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quotes',
      message: error.message
    });
  }
});

/**
 * GET /stats
 * Returns statistics about the quote service
 */
router.get('/stats', async (req, res) => {
  try {
    const stats = await db.getStats();
    
    res.json({
      success: true,
      data: {
        totalQuotes: stats.totalQuotes,
        totalRandomQuoteRequests: stats.totalViews,
        quotesAdded: quotesAddedCounter.get().values[0]?.value || 0,
        profanityBlocked: profanityBlockedCounter.get().values[0]?.value || 0
      }
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch statistics',
      message: error.message
    });
  }
});

/**
 * DELETE /quote/:id
 * Removes a quote from the database
 */
router.delete('/quote/:id', async (req, res) => {
  try {
    const id = Number.parseInt(req.params.id, 10);

    if (Number.isNaN(id) || id <= 0) {
      return res.status(400).json({
        success: false,
        error: 'Validation error',
        message: 'Quote id must be a positive integer'
      });
    }

    const removed = await db.deleteQuote(id);

    if (!removed) {
      return res.status(404).json({
        success: false,
        error: 'Not Found',
        message: `Quote with id ${id} does not exist`
      });
    }

    res.json({
      success: true,
      message: 'Quote deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting quote:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete quote',
      message: error.message
    });
  }
});

/**
 * GET /metrics
 * Returns Prometheus metrics for monitoring
 */
router.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    const metrics = await register.metrics();
    res.send(metrics);
  } catch (error) {
    console.error('Error generating metrics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate metrics',
      message: error.message
    });
  }
});

/**
 * GET /health
 * Health check endpoint
 */
router.get('/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
