// Email Server - Backend for real email connections
const express = require('express');
const cors = require('cors');
const Imap = require('imap');
const { simpleParser } = require('mailparser');
const nodemailer = require('nodemailer');
const axios = require('axios');
const crypto = require('crypto');
const fs = require('fs').promises;
const path = require('path');
const utf7 = require('utf7');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Store user sessions (in production, use Redis or database)
const sessions = new Map();

// Store drafts (in production, use database)
const drafts = new Map();

// ׳׳©׳×׳׳©׳™׳ ׳׳“׳•׳’׳׳” - ׳‘׳¡׳‘׳™׳‘׳× production ׳™׳© ׳׳©׳׳•׳¨ ׳‘׳׳¡׳“ ׳ ׳×׳•׳ ׳™׳ ׳׳׳•׳‘׳˜׳—
const APP_USERS = [
  {
    username: 'admin',
    password: '123456', // ׳‘׳¡׳‘׳™׳‘׳× production ׳™׳© ׳׳”׳©׳×׳׳© ׳‘׳”׳¦׳₪׳ ׳”!
    name: '׳׳ ׳”׳ ׳”׳׳¢׳¨׳›׳×'
  },
  {
    username: 'user1',
    password: 'password',
    name: '׳׳©׳×׳׳© ׳׳“׳•׳’׳׳”'
  }
];

// Login endpoint for the application (not email)
app.post('/api/app/login', async (req, res) => {
  const { username, password } = req.body;
  
  // ׳׳—׳₪׳© ׳׳× ׳”׳׳©׳×׳׳©
  const user = APP_USERS.find(u => u.username === username && u.password === password);
  
  if (user) {
    // ׳™׳¦׳™׳¨׳× token ׳₪׳©׳•׳˜ (׳‘׳¡׳‘׳™׳‘׳× production ׳™׳© ׳׳”׳©׳×׳׳© ׳‘-JWT)
    const token = Math.random().toString(36).substring(7);
    
    res.json({
      success: true,
      user: {
        username: user.username,
        name: user.name
      },
      token: token
    });
  } else {
    res.status(401).json({
      success: false,
      message: '׳©׳ ׳׳©׳×׳׳© ׳׳• ׳¡׳™׳¡׳׳” ׳©׳’׳•׳™׳™׳'
    });
  }
});

// Helper function to create IMAP connection
function createImapConnection(email, password, imapServer, imapPort) {
  return new Imap({
    user: email,
    password: password,
    host: imapServer,
    port: imapPort,
    tls: true,
    tlsOptions: { rejectUnauthorized: false }
  });
}

// Login and save credentials
app.post('/api/auth/login', async (req, res) => {
  const { email, password, imap_server, imap_port, smtp_server, smtp_port } = req.body;
  
  try {
    // Test IMAP connection
    const imap = createImapConnection(email, password, imap_server, imap_port);
    
    imap.once('ready', () => {
      imap.end();
      
      // Generate session ID
      const sessionId = Math.random().toString(36).substring(7);
      const session = {
        email,
        password,
        imap: { server: imap_server, port: imap_port },
        smtp: { server: smtp_server, port: smtp_port },
        claudeApiKey: '', // Will be set when user configures it
        autoReplySettings: {
          autoReplyEnabled: false,
          autoReplyOnlyWorkHours: true,
          autoReplyWorkStart: '09:00',
          autoReplyWorkEnd: '17:00',
          autoReplyWorkDays: [1, 2, 3, 4, 5],
          autoReplyOnlyPersonal: true,
          autoReplyTone: 'professional',
          autoReplyLength: 'medium',
          autoReplyCreativity: 0.7,
          autoReplyBlacklist: '',
          autoReplyWhitelist: '',
          autoReplyMaxPerDay: 5,
          autoReplyNoRepeat: true,
          autoReplyExcludeAutomated: true,
          autoReplyExcludeSpam: true,
          autoReplyNotifications: true
        }
      };
      sessions.set(sessionId, session);
      
      console.log(`[LOGIN] User ${email} logged in, session created: ${sessionId}`);
      
      res.json({ 
        success: true, 
        sessionId,
        message: '׳”׳×׳—׳‘׳¨׳× ׳‘׳”׳¦׳׳—׳”!' 
      });
    });
    
    imap.once('error', (err) => {
      res.status(401).json({ 
        success: false, 
        message: '׳©׳’׳™׳׳× ׳”׳×׳—׳‘׳¨׳•׳×: ' + err.message 
      });
    });
    
    imap.connect();
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: '׳©׳’׳™׳׳× ׳©׳¨׳×: ' + error.message 
    });
  }
});

// Get emails from folder
app.get('/api/emails/:folder', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  const folder = req.params.folder;
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const imap = createImapConnection(
    session.email, 
    session.password, 
    session.imap.server, 
    session.imap.port
  );
  
  const emails = [];
  
  imap.once('ready', () => {
    const folderName = folder === 'inbox' ? 'INBOX' : 
                      folder === 'sent' ? '[Gmail]/Sent Mail' : 
                      folder === 'drafts' ? '[Gmail]/Drafts' : 'INBOX';
    
    imap.openBox(folderName, true, (err, box) => {
      if (err) {
        imap.end();
        return res.status(500).json({ error: err.message });
      }
      
      // Fetch last 20 emails
      const fetch = imap.seq.fetch(`${Math.max(1, box.messages.total - 20)}:*`, {
        bodies: ['HEADER', 'TEXT'],
        struct: true,
        envelope: true // ׳›׳•׳׳ ׳׳¢׳˜׳₪׳” ׳¢׳ ׳׳™׳“׳¢ ׳ ׳•׳¡׳£
      });
      
      // Return more realistic mock emails for demo
      const mockEmails = [
        {
          id: "1",
          folder: folder,
          from: "support@gmail.com",
          from_name: "Gmail Team",
          to: [session.email],
          subject: "׳‘׳¨׳•׳›׳™׳ ׳”׳‘׳׳™׳ ׳-Gmail!",
          body: "<p>׳©׳׳•׳,<br><br>׳‘׳¨׳•׳›׳™׳ ׳”׳‘׳׳™׳ ׳׳—׳©׳‘׳•׳ Gmail ׳©׳׳. ׳”׳׳₪׳׳™׳§׳¦׳™׳” ׳׳—׳•׳‘׳¨׳× ׳‘׳”׳¦׳׳—׳”!</p>",
          date: new Date().toISOString(),
          is_read: false,
          is_starred: true,
          labels: ['׳“׳•׳׳¨ ׳ ׳›׳ ׳¡', '׳—׳©׳•׳‘']
        },
        {
          id: "2", 
          folder: folder,
          from: "noreply@github.com",
          from_name: "GitHub",
          to: [session.email],
          subject: "Security alert: new sign-in to your account",
          body: "<p>We noticed a new sign-in to your GitHub account from a new device.</p>",
          date: new Date(Date.now() - 3600000).toISOString(), // 1 hour ago
          is_read: true,
          is_starred: false,
          labels: ['׳“׳•׳׳¨ ׳ ׳›׳ ׳¡', '׳¢׳“׳›׳•׳ ׳™׳']
        },
        {
          id: "3",
          folder: folder,
          from: "news@newsletter.com",
          from_name: "Daily Newsletter",
          to: [session.email],
          subject: "Your daily news digest - Top stories today",
          body: "<h2>Top Stories</h2><p>Here are today's top stories...</p><ul><li>Story 1</li><li>Story 2</li></ul>",
          date: new Date(Date.now() - 7200000).toISOString(), // 2 hours ago
          is_read: false,
          is_starred: false,
          labels: ['׳“׳•׳׳¨ ׳ ׳›׳ ׳¡', '׳׳‘׳¦׳¢׳™׳']
        }
      ];
      
      // Original code - needs debugging
      const promises = [];
      
      fetch.on('message', (msg, seqno) => {
        const email = { 
          id: seqno.toString(), 
          folder: folder,
          from: '',
          from_name: 'Loading...',
          to: [],
          subject: 'Loading...',
          body: '',
          date: new Date().toISOString(),
          is_read: false,
          is_starred: false,
          labels: [] // ׳×׳•׳•׳™׳•׳× ׳©׳ ׳”׳׳™׳™׳
        };
        
        const messagePromise = new Promise((resolve) => {
          let headerData = null;
          let bodyData = null;
          let attributesSet = false;
          
          const checkComplete = () => {
            if (headerData && bodyData && attributesSet) {
              resolve(email);
            }
          };
          
          msg.on('body', (stream, info) => {
            const chunks = [];
            stream.on('data', chunk => chunks.push(chunk));
            stream.on('end', async () => {
              const buffer = Buffer.concat(chunks);
              console.log(`[DEBUG] Email ${seqno} processing ${info.which}`);
              try {
                const parsed = await simpleParser(buffer);
                
                if (info.which === 'HEADER' || info.which.includes('HEADER')) {
                  // Handle sent emails specially - they might have different structure
                  if (folder === 'sent') {
                    // For sent emails, 'from' is us, but display name should be recipient
                    email.from = session.email; // The actual sender (us)
                    email.to = parsed.to ? parsed.to.value.map(t => t.address) : [];
                    
                    // Display the first recipient's name/email as the main display name
                    if (parsed.to && parsed.to.value && parsed.to.value.length > 0) {
                      const firstRecipient = parsed.to.value[0];
                      email.from_name = firstRecipient.name || firstRecipient.address || 'Unknown Recipient';
                    } else {
                      email.from_name = 'Unknown Recipient';
                    }
                  } else {
                    // For incoming emails
                    email.from = parsed.from?.value?.[0]?.address || 'Unknown';
                    email.from_name = parsed.from?.value?.[0]?.name || parsed.from?.value?.[0]?.address || 'Unknown';
                    email.to = [session.email];
                  }
                  
                  email.subject = parsed.subject || '(׳׳׳ ׳ ׳•׳©׳)';
                  email.date = parsed.date ? parsed.date.toISOString() : new Date().toISOString();
                  email.messageId = parsed.messageId || null;
                  headerData = true;
                  console.log(`Email ${seqno} header parsed - Subject: ${email.subject}, Display name: ${email.from_name}`);
                } else {
                  // Advanced encoding detection and decoding for both sent and inbox folders
                  let bodyContent = parsed.html || parsed.text || buffer.toString();
                  
                  try {
                    if (typeof bodyContent === 'string') {
                      console.log(`[DEBUG] Original body sample for email ${seqno} in folder ${folder}:`, bodyContent.substring(0, 100));
                      
                      // Clean up binary garbage at the end of emails (mainly for inbox)
                      // Remove non-printable characters except common whitespace
                      bodyContent = bodyContent.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]/g, '');
                      
                      // Remove garbled text patterns that commonly appear in inbox emails
                      bodyContent = bodyContent
                        // Remove patterns like ן¿½M4ן¿½M4ן¿½M4ן¿½ or similar
                        .replace(/[ן¿½\uFFFD]+[M4]+[ן¿½\uFFFD]*[M4]*[ן¿½\uFFFD]*/g, '')
                        // Remove isolated binary-looking sequences
                        .replace(/[ן¿½\uFFFD]+[a-zA-Z0-9_\-:¶]+[ן¿½\uFFFD]*/g, '')
                        // Remove sequences that look like encoding artifacts
                        .replace(/[ן¿½\uFFFD]{2,}/g, '')
                        // Clean up patterns with mixed special chars and letters
                        .replace(/[ן¿½\uFFFD][a-zA-Z0-9]{1,3}[ן¿½\uFFFD]/g, '')
                        // Remove suspicious character combinations at the end
                        .replace(/[ן¿½\uFFFD\\:¶o_t z{Sֺ—{¥r]+$/g, '')
                        .trim();
                      
                      // Check if content needs decoding
                      const hasReadableText = /[׳-׳×]{3,}|[a-zA-Z]{3,}/.test(bodyContent);
                      
                      // For sent folder, be more aggressive with Base64 decoding
                      if (folder === 'sent' || !hasReadableText) {
                        // Method 1: Try Base64 decoding if it looks like base64
                        const cleanContent = bodyContent.replace(/\s/g, '');
                        const base64Regex = /^[A-Za-z0-9+/]+={0,2}$/;
                        
                        if (cleanContent.length > 50 && base64Regex.test(cleanContent)) {
                          try {
                            const decoded = Buffer.from(cleanContent, 'base64').toString('utf8');
                            // For sent emails, be more liberal in accepting decoded content
                            if ((folder === 'sent' && decoded.length > 10) || /[׳-׳×]{3,}|[a-zA-Z]{3,}/.test(decoded)) {
                              bodyContent = decoded;
                              console.log(`[DEBUG] Successfully decoded base64 body for email ${seqno} in ${folder}`);
                            }
                          } catch (base64Error) {
                            console.log(`[DEBUG] Base64 decode failed for email ${seqno} in ${folder}`);
                          }
                        }
                        
                        // Method 1.5: If still looks like Base64, try partial decoding (for sent emails mainly)
                        if (folder === 'sent' && bodyContent.length > 100 && /^[A-Za-z0-9+/=\s]+$/.test(bodyContent)) {
                          try {
                            // Try to decode even if there are some spaces/newlines
                            const partialClean = bodyContent.replace(/[\r\n\s]/g, '');
                            if (partialClean.length > 50) {
                              const decoded = Buffer.from(partialClean, 'base64').toString('utf8');
                              if (decoded.includes('<') || decoded.includes('׳') || decoded.includes('׳©') || decoded.length > bodyContent.length * 0.3) {
                                bodyContent = decoded;
                                console.log(`[DEBUG] Successfully decoded partial base64 for sent email ${seqno}`);
                              }
                            }
                          } catch (partialError) {
                            console.log(`[DEBUG] Partial base64 decode failed for email ${seqno}`);
                          }
                        }
                      }
                      
                      // Method 2: Handle MIME encoded-words (for all folders)
                      if (bodyContent.includes('=?UTF-8?B?') || bodyContent.includes('=?utf-8?B?')) {
                        bodyContent = bodyContent
                          .replace(/=\?UTF-8\?B\?([^?]+)\?=/g, (match, encoded) => {
                            try {
                              return Buffer.from(encoded, 'base64').toString('utf8');
                            } catch { return match; }
                          })
                          .replace(/=\?utf-8\?B\?([^?]+)\?=/gi, (match, encoded) => {
                            try {
                              return Buffer.from(encoded, 'base64').toString('utf8');
                            } catch { return match; }
                          });
                      }
                      
                      // Final cleanup: remove any remaining garbled text at the end (mainly for inbox)
                      if (folder !== 'sent') {
                        bodyContent = bodyContent.replace(/[ן¿½\uFFFD]+.*$/g, '').trim();
                      }
                      
                      console.log(`[DEBUG] Final body sample for email ${seqno} in ${folder}:`, bodyContent.substring(0, 100));
                    }
                  } catch (decodeError) {
                    console.log(`[DEBUG] Could not decode body for email ${seqno} in ${folder}:`, decodeError.message);
                  }
                  
                  email.body = bodyContent;
                  bodyData = true;
                }
                
                checkComplete();
              } catch (e) {
                console.error(`Error parsing ${info.which} for email ${seqno}:`, e);
                if (info.which === 'HEADER' || info.which.includes('HEADER')) {
                  headerData = true;
                } else {
                  bodyData = true;
                }
                checkComplete();
              }
            });
          });
          
          msg.once('attributes', (attrs) => {
            email.is_read = attrs.flags.includes('\\Seen');
            email.is_starred = attrs.flags.includes('\\Flagged');
            
            // ׳©׳׳•׳£ ׳×׳•׳•׳™׳•׳× Gmail
            if (attrs['x-gm-labels']) {
              console.log(`\n=== Email ${seqno} Labels Debug ===`);
              console.log('Raw labels:', attrs['x-gm-labels']);
              console.log('Raw labels JSON:', JSON.stringify(attrs['x-gm-labels']));
              
              const processedLabels = [];
              
              for (let label of attrs['x-gm-labels']) {
                const original = label;
                // ׳”׳׳¨ ׳string ׳•׳ ׳§׳”
                let cleaned = String(label).trim();
                
                // ׳”׳¡׳¨ backslashes ׳‘׳”׳×׳—׳׳” ׳•׳‘׳¡׳•׳£
                cleaned = cleaned.replace(/^\\+/, '').replace(/\\+$/, '');
                
                console.log(`Processing: "${original}" -> "${cleaned}"`);
                
                // ׳‘׳“׳•׳§ ׳׳ ׳–׳• ׳×׳•׳•׳™׳× ׳׳§׳•׳“׳“׳× ׳‘׳¢׳‘׳¨׳™׳× (modified UTF-7)
                if (cleaned.includes('&') && cleaned.endsWith('-')) {
                  try {
                    // ׳₪׳¢׳ ׳•׳— Modified UTF-7 ׳׳¢׳‘׳¨׳™׳×
                    // Gmail ׳׳©׳×׳׳© ׳‘-IMAP Modified UTF-7 (RFC 3501)
                    const decoded = utf7.imap.decode(cleaned);
                    
                    // ׳‘׳“׳•׳§ ׳׳ ׳”׳₪׳¢׳ ׳•׳— ׳”׳¦׳׳™׳— ׳•׳ ׳×׳ ׳¢׳‘׳¨׳™׳×
                    if (decoded && decoded !== cleaned && /[\u0590-\u05FF]/.test(decoded)) {
                      processedLabels.push(decoded);
                      console.log(`  Auto-decoded Hebrew: "${cleaned}" -> "${decoded}"`);
                      continue;
                    }
                  } catch (e) {
                    console.log(`  Failed to decode: "${cleaned}" - ${e.message}`);
                  }
                  
                  // ׳׳ ׳”׳₪׳¢׳ ׳•׳— ׳ ׳›׳©׳, ׳ ׳¡׳” ׳©׳™׳˜׳” ׳׳—׳¨׳×
                  try {
                    // ׳©׳™׳˜׳” 2: Modified Base64 to UTF-16
                    const base64Part = cleaned.substring(1, cleaned.length - 1); // ׳”׳¡׳¨ & ׳•-
                    const modifiedBase64 = base64Part
                      .replace(/,/g, '/')  // Gmail ׳׳©׳×׳׳© ׳‘-, ׳‘׳׳§׳•׳ /
                      .replace(/_/g, '/'); // ׳•׳׳₪׳¢׳׳™׳ _ ׳‘׳׳§׳•׳ /
                      
                    // ׳₪׳¢׳ ׳— ׳-base64 ׳-buffer
                    const buffer = Buffer.from(modifiedBase64, 'base64');
                    
                    // ׳ ׳¡׳” ׳׳₪׳¢׳ ׳— ׳›-UTF-16BE (Big Endian)
                    const decoded = buffer.toString('utf16le').replace(/\0/g, '');
                    
                    if (decoded && /[\u0590-\u05FF]/.test(decoded)) {
                      processedLabels.push(decoded);
                      console.log(`  Auto-decoded Hebrew (method 2): "${cleaned}" -> "${decoded}"`);
                      continue;
                    }
                  } catch (e2) {
                    // ׳׳ ׳’׳ ׳–׳” ׳ ׳›׳©׳, ׳₪׳©׳•׳˜ ׳”׳¦׳’ ׳׳× ׳”׳×׳•׳•׳™׳× ׳”׳׳§׳•׳“׳“׳×
                  }
                  
                  // ׳׳ ׳©׳•׳ ׳“׳‘׳¨ ׳׳ ׳¢׳‘׳“, ׳”׳¦׳’ ׳׳× ׳”׳×׳•׳•׳™׳× ׳”׳׳§׳•׳“׳“׳×
                  console.log(`  Could not decode: "${cleaned}"`);
                  processedLabels.push(`[${cleaned}]`);
                  continue;
                }
                
                // ׳“׳׳’ ׳¢׳ ׳×׳•׳•׳™׳•׳× ׳¢׳ ׳×׳•׳•׳™׳ ׳׳™׳•׳—׳“׳™׳ ׳׳—׳¨׳™׳
                if (cleaned.startsWith('-')) {
                  console.log(`  Skipped: Starts with dash`);
                  continue;
                }
                
                // ׳׳₪׳× ׳×׳¨׳’׳•׳׳™׳
                const upperLabel = cleaned.toUpperCase();
                const labelMap = {
                  'INBOX': '׳“׳•׳׳¨ ׳ ׳›׳ ׳¡',
                  'IMPORTANT': '׳—׳©׳•׳‘',
                  'CATEGORY_SOCIAL': '׳¨׳©׳×׳•׳× ׳—׳‘׳¨׳×׳™׳•׳×',
                  'CATEGORY_PROMOTIONS': '׳׳‘׳¦׳¢׳™׳',
                  'CATEGORY_UPDATES': '׳¢׳“׳›׳•׳ ׳™׳',
                  'CATEGORY_FORUMS': '׳₪׳•׳¨׳•׳׳™׳',
                  'CATEGORY_PERSONAL': '׳׳™׳©׳™',
                  'UNREAD': '׳׳ ׳ ׳§׳¨׳',
                  'STARRED': '׳׳¡׳•׳׳ ׳‘׳›׳•׳›׳‘',
                  'DRAFT': '׳˜׳™׳•׳˜׳”',
                  'SENT': '׳ ׳©׳׳—',
                  'SPAM': '׳¡׳₪׳׳',
                  'TRASH': '׳׳©׳₪׳”',
                  'CATEGORY_PRIMARY': '׳¨׳׳©׳™',
                  'READ': '׳ ׳§׳¨׳',
                  'SNOOZED': '׳ ׳“׳—׳”',
                  'ARCHIVED': '׳‘׳׳¨׳›׳™׳•׳'
                };
                
                // ׳‘׳“׳•׳§ ׳׳ ׳”׳×׳•׳•׳™׳× ׳›׳‘׳¨ ׳‘׳¢׳‘׳¨׳™׳×
                if (/[\u0590-\u05FF]/.test(cleaned)) {
                  processedLabels.push(cleaned);
                  console.log(`  Already Hebrew: "${cleaned}"`);
                } else if (labelMap[upperLabel]) {
                  // ׳™׳© ׳×׳¨׳’׳•׳ ׳‘׳׳™׳׳•׳
                  processedLabels.push(labelMap[upperLabel]);
                  console.log(`  Translated: "${cleaned}" -> "${labelMap[upperLabel]}"`);
                } else if (cleaned.length <= 20) { // ׳”׳’׳“׳ ׳׳× ׳”׳’׳‘׳•׳ ׳-20
                  processedLabels.push(cleaned);
                  console.log(`  Kept original: "${cleaned}"`);
                } else {
                  console.log(`  Skipped: Too long (${cleaned.length} chars)`);
                }
              }
              
              email.labels = processedLabels;
              console.log('Final labels:', email.labels);
              console.log('=== End Labels Debug ===\n');
            } else {
              // ׳¢׳‘׳•׳¨ ׳¡׳₪׳§׳™ ׳“׳•׳"׳ ׳׳—׳¨׳™׳, ׳”׳©׳×׳׳© ׳‘׳×׳™׳§׳™׳•׳×
              email.labels = [folder === 'inbox' ? '׳“׳•׳׳¨ ׳ ׳›׳ ׳¡' : folder === 'sent' ? '׳ ׳©׳׳—' : folder];
            }
            
            attributesSet = true;
            checkComplete();
          });
          
          // Timeout fallback
          setTimeout(() => {
            if (!headerData) headerData = true;
            if (!bodyData) bodyData = true;
            if (!attributesSet) attributesSet = true;
            checkComplete();
          }, 5000);
        });
        
        promises.push(messagePromise);
      });
      
      fetch.once('error', (err) => {
        console.error('Fetch error:', err);
      });
      
      fetch.once('end', async () => {
        try {
          if (promises.length === 0) {
            // No emails found, return mock email
            imap.end();
            return res.json(mockEmails);
          }
          
          const resolvedEmails = await Promise.all(promises);
          imap.end();
          res.json(resolvedEmails.reverse()); // Newest first
        } catch (error) {
          console.error('Error processing emails:', error);
          imap.end();
          res.json(mockEmails); // Return mock on error
        }
      });
    });
  });
  
  imap.once('error', (err) => {
    res.status(500).json({ error: err.message });
  });
  
  imap.connect();
});

// Send email
app.post('/api/emails/send', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const { to, subject, body } = req.body;
  
  try {
    const transporter = nodemailer.createTransport({
      host: session.smtp.server,
      port: session.smtp.port,
      secure: session.smtp.port === 465,
      auth: {
        user: session.email,
        pass: session.password
      }
    });
    
    const mailOptions = {
      from: session.email,
      to: to,
      subject: subject,
      html: body,
      text: body.replace(/<[^>]*>/g, ''), // Add plain text version
      headers: {
        'Content-Type': 'text/html; charset=UTF-8',
        'Content-Transfer-Encoding': '8bit', // Changed from base64 to 8bit
        'MIME-Version': '1.0'
      }
    };
    
    const info = await transporter.sendMail(mailOptions);

    // After sending, append it to the 'Sent' folder with proper format
    const imap = createImapConnection(
      session.email, 
      session.password, 
      session.imap.server, 
      session.imap.port
    );

    // Create a proper MIME message
    const messageDate = new Date().toUTCString();
    const fullMessage = `From: ${session.email}\r\n` +
                        `To: ${Array.isArray(to) ? to.join(', ') : to}\r\n` +
                        `Subject: ${subject}\r\n` +
                        `Date: ${messageDate}\r\n` +
                        `MIME-Version: 1.0\r\n` +
                        `Content-Type: text/html; charset=UTF-8\r\n` +
                        `Content-Transfer-Encoding: 8bit\r\n` +
                        `\r\n` +
                        `${body}`;

    imap.once('ready', () => {
      imap.append(fullMessage, { mailbox: '[Gmail]/Sent Mail', flags: ['\\Seen'] }, (err) => {
        if (err) {
          console.error('Error appending to sent folder:', err);
        }
        imap.end();
      });
    });
    imap.connect();

    res.json({ 
      success: true, 
      messageId: info.messageId,
      message: '׳”׳׳™׳™׳ ׳ ׳©׳׳— ׳‘׳”׳¦׳׳—׳”!' 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: '׳©׳’׳™׳׳” ׳‘׳©׳׳™׳—׳× ׳”׳׳™׳™׳: ' + error.message 
    });
  }
});

// Update email (mark as read, star, etc.)
app.put('/api/emails/:id', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  const emailId = req.params.id;
  const { is_read, is_starred } = req.body;
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const imap = createImapConnection(
    session.email, 
    session.password, 
    session.imap.server, 
    session.imap.port
  );
  
  imap.once('ready', () => {
    imap.openBox('INBOX', false, (err, box) => {
      if (err) {
        imap.end();
        return res.status(500).json({ error: err.message });
      }
      
      const flags = [];
      if (is_read !== undefined) {
        flags.push(is_read ? '\\Seen' : '-\\Seen');
      }
      if (is_starred !== undefined) {
        flags.push(is_starred ? '\\Flagged' : '-\\Flagged');
      }
      
      imap.seq.addFlags(emailId, flags, (err) => {
        imap.end();
        if (err) {
          return res.status(500).json({ error: err.message });
        }
        res.json({ success: true });
      });
    });
  });
  
  imap.connect();
});

// ׳₪׳•׳ ׳§׳¦׳™׳” ׳׳‘׳ ׳™׳™׳× system prompt ׳׳©׳•׳₪׳¨
const buildSystemPrompt = (customPrompt, basePrompt, settings) => {
  let finalPrompt = basePrompt;
  
  if (customPrompt) {
    finalPrompt = customPrompt + '\n\n' + basePrompt;
  }
  
  // ׳”׳•׳¡׳£ ׳”׳’׳“׳¨׳•׳× ׳¡׳₪׳¦׳™׳₪׳™׳•׳×
  if (settings) {
    if (settings.language && settings.language !== 'auto') {
      const languageMap = {
        'hebrew': '׳¢׳‘׳¨׳™׳×',
        'english': 'English',
        'arabic': '״§„״¹״±״¨״©',
        'russian': '׀ ׁƒׁׁ׀÷׀¸׀¹'
      };
      finalPrompt += `\n׳›׳×׳•׳‘ ׳‘${languageMap[settings.language] || settings.language}.`;
    }
    if (settings.maxLength) {
      finalPrompt += `\n׳”׳’׳‘׳ ׳׳× ׳”׳×׳©׳•׳‘׳” ׳-${settings.maxLength} ׳׳™׳׳™׳ ׳׳›׳ ׳”׳™׳•׳×׳¨.`;
    }
    if (settings.autoCorrect) {
      finalPrompt += `\n׳×׳§׳ ׳©׳’׳™׳׳•׳× ׳›׳×׳™׳‘ ׳•׳“׳§׳“׳•׳§.`;
    }
  }
  
  return finalPrompt;
};

// Claude AI endpoints
app.post('/api/claude/generate', async (req, res) => {
  const { prompt, system, apiKey } = req.body;
  
  if (!apiKey) {
    return res.status(400).json({ error: 'API key is required' });
  }

  try {
    const response = await axios.post('https://api.anthropic.com/v1/messages', {
      model: 'claude-3-haiku-20240307',
      max_tokens: 1024,
      messages: [
        {
          role: 'user',
          content: prompt
        }
      ],
      system: system || 'You are a helpful email assistant that writes professional, concise email responses.'
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      }
    });

    res.json({ text: response.data.content[0].text });
  } catch (error) {
    console.error('Claude API Error:', error.response?.data || error.message);
    
    if (error.response) {
      // Error from Anthropic API
      const status = error.response.status;
      const errorMessage = error.response.data?.error?.message || error.response.data?.error || 'Claude API error';
      res.status(status).json({ error: errorMessage });
    } else {
      // Network or other error
      res.status(500).json({ error: error.message });
    }
  }
});

// Smart reply endpoint
app.post('/api/claude/smart-reply', async (req, res) => {
  const { emailContent, apiKey, settings, customSystemPrompt } = req.body;
  
  if (!apiKey) {
    return res.status(400).json({ error: 'API key is required' });
  }

  const baseSystemPrompt = '׳׳×׳” ׳¢׳•׳–׳¨ ׳“׳•׳׳¨ ׳׳׳§׳˜׳¨׳•׳ ׳™ ׳©׳›׳•׳×׳‘ ׳×׳©׳•׳‘׳•׳× ׳׳§׳¦׳•׳¢׳™׳•׳× ׳׳ ׳™׳“׳™׳“׳•׳×׳™׳•׳×. ׳”׳×׳׳ ׳׳× ׳”׳©׳₪׳” ׳׳©׳₪׳× ׳”׳׳™׳™׳ ׳”׳׳§׳•׳¨׳™.';
  const systemPrompt = buildSystemPrompt(customSystemPrompt, baseSystemPrompt, settings);

  // ׳‘׳ ׳™׳™׳× ׳×׳•׳›׳ ׳”׳׳™׳™׳ ׳”׳׳׳
  let fullEmailContent = '';
  if (typeof emailContent === 'object') {
    fullEmailContent = `׳׳׳×: ${emailContent.from || 'Unknown'}\n`;
    fullEmailContent += `׳ ׳•׳©׳: ${emailContent.subject || 'No Subject'}\n`;
    fullEmailContent += `׳×׳׳¨׳™׳: ${emailContent.date || 'Unknown'}\n\n`;
    fullEmailContent += `׳×׳•׳›׳ ׳”׳׳™׳™׳:\n${emailContent.body || 'No content'}`;
  } else {
    fullEmailContent = emailContent;
  }

  try {
    const response = await axios.post('https://api.anthropic.com/v1/messages', {
      model: 'claude-3-haiku-20240307',
      max_tokens: settings?.maxLength || 500,
      temperature: settings?.creativity || 0.7,
      messages: [
        {
          role: 'user',
          content: `׳›׳×׳•׳‘ ׳×׳©׳•׳‘׳” ${settings?.tone === 'formal' ? '׳₪׳•׳¨׳׳׳™׳×' : settings?.tone === 'friendly' ? '׳™׳“׳™׳“׳•׳×׳™׳×' : '׳׳§׳¦׳•׳¢׳™׳×'} ׳׳׳™׳™׳ ׳”׳–׳”.

׳—׳©׳•׳‘ ׳׳׳•׳“: ׳₪׳¨׳§ ׳׳× ׳”׳×׳©׳•׳‘׳” ׳׳₪׳™׳¡׳§׳׳•׳× ׳ ׳₪׳¨׳“׳•׳× ׳¢׳ ׳©׳•׳¨׳•׳× ׳¨׳™׳§׳•׳× ׳‘׳™׳ ׳™׳”׳. ׳›׳ ׳¨׳¢׳™׳•׳ ׳׳• ׳ ׳•׳©׳ ׳׳׳•׳¨ ׳׳”׳™׳•׳× ׳‘׳₪׳™׳¡׳§׳” ׳ ׳₪׳¨׳“׳×.

׳“׳•׳’׳׳” ׳׳₪׳•׳¨׳׳˜ ׳ ׳›׳•׳:
׳©׳׳•׳ [׳©׳],

׳×׳•׳“׳” ׳׳ ׳¢׳ ׳₪׳ ׳™׳™׳×׳ ׳‘׳ ׳•׳©׳...

׳‘׳ ׳•׳’׳¢ ׳׳©׳׳׳×׳, ׳׳ ׳™ ׳¨׳•׳¦׳” ׳׳¢׳ ׳•׳×...

׳׳©׳׳— ׳׳¢׳׳•׳“ ׳׳¨׳©׳•׳×׳ ׳׳›׳ ׳©׳׳׳” ׳ ׳•׳¡׳₪׳×.

׳‘׳‘׳¨׳›׳”,
[׳©׳]

׳”׳׳™׳™׳ ׳׳׳¢׳ ׳”:
${fullEmailContent}`
        }
      ],
      system: systemPrompt
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      }
    });

    res.json({ reply: response.data.content[0].text });
  } catch (error) {
    console.error('Smart Reply Error:', error.response?.data || error.message);
    if (error.response) {
      res.status(error.response.status).json({ error: error.response.data?.error?.message || 'Smart reply error' });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

// Generate subject endpoint
app.post('/api/claude/generate-subject', async (req, res) => {
  const { emailBody, apiKey, settings, customSystemPrompt } = req.body;
  
  if (!apiKey) {
    return res.status(400).json({ error: 'API key is required' });
  }

  const baseSystemPrompt = '׳׳×׳” ׳׳•׳׳—׳” ׳‘׳™׳¦׳™׳¨׳× ׳›׳•׳×׳¨׳•׳× ׳׳™׳™׳׳™׳. ׳¦׳•׳¨ ׳›׳•׳×׳¨׳•׳× ׳§׳¦׳¨׳•׳×, ׳׳׳•׳§׳“׳•׳× ׳•׳׳§׳¦׳•׳¢׳™׳•׳×.';
  const systemPrompt = buildSystemPrompt(customSystemPrompt, baseSystemPrompt, settings);

  try {
    const response = await axios.post('https://api.anthropic.com/v1/messages', {
      model: 'claude-3-haiku-20240307',
      max_tokens: 50,
      temperature: settings?.creativity || 0.7,
      messages: [
        {
          role: 'user',
          content: `׳¦׳•׳¨ ׳›׳•׳×׳¨׳× ׳§׳¦׳¨׳” ׳•׳׳׳•׳§׳“׳× ׳׳׳™׳™׳ ׳”׳‘׳. ׳”׳—׳–׳¨ ׳¨׳§ ׳׳× ׳”׳›׳•׳×׳¨׳× ׳‘׳׳‘׳“:\n\n${emailBody}`
        }
      ],
      system: systemPrompt
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      }
    });

    res.json({ subject: response.data.content[0].text });
  } catch (error) {
    console.error('Generate Subject Error:', error.response?.data || error.message);
    if (error.response) {
      res.status(error.response.status).json({ error: error.response.data?.error?.message || 'Subject generation error' });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

// Improve email endpoint
app.post('/api/claude/improve-email', async (req, res) => {
  const { emailContent, style, apiKey, settings, customSystemPrompt } = req.body;
  
  if (!apiKey) {
    return res.status(400).json({ error: 'API key is required' });
  }

  const stylePrompts = {
    professional: '׳©׳₪׳¨ ׳׳× ׳”׳׳™׳™׳ ׳׳¡׳’׳ ׳•׳ ׳׳§׳¦׳•׳¢׳™ ׳•׳₪׳•׳¨׳׳׳™',
    friendly: '׳©׳₪׳¨ ׳׳× ׳”׳׳™׳™׳ ׳׳¡׳’׳ ׳•׳ ׳™׳“׳™׳“׳•׳×׳™ ׳•׳—׳',
    concise: '׳§׳¦׳¨ ׳׳× ׳”׳׳™׳™׳ ׳•׳”׳₪׳•׳ ׳׳•׳×׳• ׳׳×׳׳¦׳™׳×׳™ ׳•׳™׳©׳™׳¨ ׳׳¢׳ ׳™׳™׳'
  };

  const baseSystemPrompt = '׳׳×׳” ׳¢׳•׳¨׳ ׳׳™׳™׳׳™׳ ׳׳§׳¦׳•׳¢׳™ ׳©׳׳©׳₪׳¨ ׳׳× ׳”׳¡׳’׳ ׳•׳ ׳•׳”׳‘׳”׳™׳¨׳•׳× ׳׳‘׳׳™ ׳׳©׳ ׳•׳× ׳׳× ׳”׳×׳•׳›׳.';
  const systemPrompt = buildSystemPrompt(customSystemPrompt, baseSystemPrompt, settings);

  try {
    const response = await axios.post('https://api.anthropic.com/v1/messages', {
      model: 'claude-3-haiku-20240307',
      max_tokens: settings?.maxLength || 1000,
      temperature: settings?.creativity || 0.7,
      messages: [
        {
          role: 'user',
          content: `${stylePrompts[style] || stylePrompts.professional}. ׳©׳׳•׳¨ ׳¢׳ ׳”׳׳©׳׳¢׳•׳× ׳”׳׳§׳•׳¨׳™׳×:\n\n${emailContent}`
        }
      ],
      system: systemPrompt
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      }
    });

    res.json({ improved: response.data.content[0].text });
  } catch (error) {
    console.error('Improve Email Error:', error.response?.data || error.message);
    if (error.response) {
      res.status(error.response.status).json({ error: error.response.data?.error?.message || 'Email improvement error' });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

// ============= DRAFTS API - ׳ ׳™׳”׳•׳ ׳˜׳™׳•׳˜׳•׳× =============

// ׳©׳׳™׳¨׳× ׳˜׳™׳•׳˜׳” ׳‘-Gmail ׳”׳׳§׳•׳¨׳™ ׳¢׳ ׳×׳•׳•׳™׳× "׳׳׳×׳™׳ ׳׳©׳׳™׳—׳”"
app.post('/api/drafts/save', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const { originalEmail, draftContent, subject } = req.body;
  
  try {
    const draftId = Math.random().toString(36).substring(7);
    
    // Create IMAP connection to save draft in Gmail
    const imap = createImapConnection(
      session.email, 
      session.password, 
      session.imap.server, 
      session.imap.port
    );

    // Create a properly formatted MIME message for the draft
    const messageDate = new Date().toUTCString();
    const toEmail = originalEmail.from; // Reply to original sender
    const draftSubject = `[׳׳׳×׳™׳ ׳׳©׳׳™׳—׳”] ${subject}`; // Add identifier to subject
    
    // Format the draft content professionally with intelligent paragraph detection
    let formattedContent = draftContent;
    
    console.log(`[DEBUG] Original draft content:`, draftContent);
    
    // If content doesn't have HTML tags, format it properly
    if (!formattedContent.includes('<html>') && !formattedContent.includes('<div>')) {
      
      // Step 1: Split by actual line breaks first
      let paragraphs = formattedContent.split('\n').map(line => line.trim()).filter(line => line.length > 0);
      
      // Step 2: If we have very few paragraphs but long text, try intelligent splitting
      if (paragraphs.length <= 2 && formattedContent.length > 100) {
        console.log(`[DEBUG] Attempting intelligent paragraph splitting...`);
        
        // Split by common sentence patterns in Hebrew/English
        const intelligentSplit = formattedContent
          // Split after periods followed by space and capital letter or Hebrew letter
          .replace(/(\.)(\s+)([A-Z\u0590-\u05FF])/g, '$1\n\n$3')
          // Split after question marks
          .replace(/(\?)(\s+)([A-Z\u0590-\u05FF])/g, '$1\n\n$3')
          // Split after exclamation marks
          .replace(/(\!)(\s+)([A-Z\u0590-\u05FF])/g, '$1\n\n$3')
          // Split at common greeting patterns
          .replace(/(׳©׳׳•׳[^,]*,)(\s*)/g, '$1\n\n')
          .replace(/(׳”׳™׳™[^,]*,)(\s*)/g, '$1\n\n')
          .replace(/(׳×׳•׳“׳”[^.]*\.)(\s+)/g, '$1\n\n')
          .replace(/(׳‘׳‘׳¨׳›׳”[^,]*,?)(\s*)/g, '\n\n$1\n\n')
          // Split at transition words
          .replace(/(׳‘׳ ׳•׳’׳¢ ׳[^,]*,?)(\s+)/g, '\n\n$1 ')
          .replace(/(׳‘׳ ׳•׳©׳[^,]*,?)(\s+)/g, '\n\n$1 ')
          .replace(/(׳׳’׳‘׳™[^,]*,?)(\s+)/g, '\n\n$1 ')
          .replace(/(׳׳©׳׳—[^.]*\.)(\s+)/g, '$1\n\n');
        
        paragraphs = intelligentSplit.split('\n').map(line => line.trim()).filter(line => line.length > 0);
        console.log(`[DEBUG] After intelligent splitting, got ${paragraphs.length} paragraphs:`, paragraphs);
      }
      
      // Step 3: Format each paragraph as HTML
      formattedContent = paragraphs
        .map(paragraph => `<p style="margin: 0 0 12px 0; line-height: 1.5;">${paragraph}</p>`)
        .join('');
      
      console.log(`[DEBUG] Final formatted paragraphs:`, formattedContent);
      
      // Wrap in professional HTML structure
      formattedContent = `
<!DOCTYPE html>
<html dir="rtl" lang="he">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            font-size: 14px; 
            line-height: 1.6; 
            color: #333; 
            direction: rtl; 
            text-align: right;
            margin: 0;
            padding: 20px;
        }
        .email-content { 
            max-width: 600px; 
            margin: 0 auto; 
        }
        p { 
            margin: 0 0 12px 0; 
            line-height: 1.5; 
        }
        .signature {
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #ddd;
            color: #666;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="email-content">
        ${formattedContent}
        
        <div class="signature">
            <p>׳‘׳‘׳¨׳›׳”,<br>
            ׳ ׳©׳׳— ׳׳×׳•׳›׳ ׳× ׳”׳“׳•׳"׳ ׳”׳—׳›׳׳”</p>
        </div>
    </div>
</body>
</html>`;
    }
    
    console.log(`[DEBUG] Final HTML content length:`, formattedContent.length);
    
    const draftMessage = `From: ${session.email}\r\n` +
                          `To: ${toEmail}\r\n` +
                          `Subject: ${draftSubject}\r\n` +
                          `Date: ${messageDate}\r\n` +
                          `MIME-Version: 1.0\r\n` +
                          `Content-Type: text/html; charset=UTF-8\r\n` +
                          `Content-Transfer-Encoding: 8bit\r\n` +
                          `References: ${originalEmail.messageId || ''}\r\n` +
                          `In-Reply-To: ${originalEmail.messageId || ''}\r\n` +
                          `\r\n` +
                          `${formattedContent}`;

    imap.once('ready', () => {
      // Save draft in Gmail's Drafts folder
      imap.append(draftMessage, { 
        mailbox: '[Gmail]/Drafts', 
        flags: ['\\Draft'] 
      }, (err) => {
        if (err) {
          console.error('Error saving draft to Gmail:', err);
          imap.end();
          return res.status(500).json({ 
            error: '׳©׳’׳™׳׳” ׳‘׳©׳׳™׳¨׳× ׳”׳˜׳™׳•׳˜׳” ׳‘-Gmail',
            details: err.message 
          });
        }
        
        console.log(`Draft saved successfully to Gmail for ${session.email}`);
        imap.end();
        
        // Also save locally for backup and quick access
        const draft = {
          id: draftId,
          userEmail: session.email,
          originalEmail: originalEmail,
          draftContent: draftContent,
          subject: subject,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          savedInGmail: true
        };
        
        if (!drafts.has(session.email)) {
          drafts.set(session.email, []);
        }
        drafts.get(session.email).push(draft);
        
        res.json({ 
          success: true, 
          draftId: draftId,
          message: '׳”׳˜׳™׳•׳˜׳” ׳ ׳©׳׳¨׳” ׳‘׳”׳¦׳׳—׳” ׳‘-Gmail! ׳”׳ ׳•׳©׳ ׳™׳›׳׳•׳ "[׳׳׳×׳™׳ ׳׳©׳׳™׳—׳”]" ׳׳׳–׳”׳•׳™ ׳§׳.',
          savedInGmail: true
        });
      });
    });

    imap.once('error', (err) => {
      console.error('IMAP connection error while saving draft:', err);
      res.status(500).json({ 
        error: '׳©׳’׳™׳׳” ׳‘׳—׳™׳‘׳•׳¨ ׳-Gmail',
        details: err.message 
      });
    });

    imap.connect();
    
  } catch (error) {
    console.error('Error in draft save process:', error);
    res.status(500).json({ 
      error: '׳©׳’׳™׳׳” ׳‘׳©׳׳™׳¨׳× ׳”׳˜׳™׳•׳˜׳”',
      details: error.message 
    });
  }
});

// ׳§׳‘׳׳× ׳›׳ ׳”׳˜׳™׳•׳˜׳•׳× ׳©׳ ׳”׳׳©׳×׳׳©
app.get('/api/drafts', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const userDrafts = drafts.get(session.email) || [];
  res.json(userDrafts);
});

// ׳§׳‘׳׳× ׳˜׳™׳•׳˜׳” ׳¡׳₪׳¦׳™׳₪׳™׳×
app.get('/api/drafts/:id', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  const draftId = req.params.id;
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const userDrafts = drafts.get(session.email) || [];
  const draft = userDrafts.find(d => d.id === draftId);
  
  if (!draft) {
    return res.status(404).json({ error: '׳˜׳™׳•׳˜׳” ׳׳ ׳ ׳׳¦׳׳”' });
  }
  
  res.json(draft);
});

// ׳¢׳“׳›׳•׳ ׳˜׳™׳•׳˜׳”
app.put('/api/drafts/:id', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  const draftId = req.params.id;
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const userDrafts = drafts.get(session.email) || [];
  const draftIndex = userDrafts.findIndex(d => d.id === draftId);
  
  if (draftIndex === -1) {
    return res.status(404).json({ error: '׳˜׳™׳•׳˜׳” ׳׳ ׳ ׳׳¦׳׳”' });
  }
  
  // ׳¢׳“׳›׳ ׳׳× ׳”׳˜׳™׳•׳˜׳”
  userDrafts[draftIndex] = {
    ...userDrafts[draftIndex],
    ...req.body,
    updatedAt: new Date().toISOString()
  };
  
  res.json({ 
    success: true, 
    message: '׳”׳˜׳™׳•׳˜׳” ׳¢׳•׳“׳›׳ ׳” ׳‘׳”׳¦׳׳—׳”' 
  });
});

// ׳׳—׳™׳§׳× ׳˜׳™׳•׳˜׳”
app.delete('/api/drafts/:id', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  const draftId = req.params.id;
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const userDrafts = drafts.get(session.email) || [];
  const filteredDrafts = userDrafts.filter(d => d.id !== draftId);
  
  if (filteredDrafts.length === userDrafts.length) {
    return res.status(404).json({ error: '׳˜׳™׳•׳˜׳” ׳׳ ׳ ׳׳¦׳׳”' });
  }
  
  drafts.set(session.email, filteredDrafts);
  
  res.json({ 
    success: true, 
    message: '׳”׳˜׳™׳•׳˜׳” ׳ ׳׳—׳§׳” ׳‘׳”׳¦׳׳—׳”' 
  });
});

// ׳©׳׳™׳—׳× ׳˜׳™׳•׳˜׳” ׳›׳×׳©׳•׳‘׳” ׳‘׳©׳¨׳©׳•׳¨
app.post('/api/drafts/:id/send', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  const draftId = req.params.id;
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const userDrafts = drafts.get(session.email) || [];
  const draft = userDrafts.find(d => d.id === draftId);
  
  if (!draft) {
    return res.status(404).json({ error: '׳˜׳™׳•׳˜׳” ׳׳ ׳ ׳׳¦׳׳”' });
  }
  
  try {
    const transporter = nodemailer.createTransport({
      host: session.smtp.server,
      port: session.smtp.port,
      secure: session.smtp.port === 465,
      auth: {
        user: session.email,
        pass: session.password
      }
    });
    
    // ׳‘׳ ׳” ׳×׳©׳•׳‘׳” ׳‘׳©׳¨׳©׳•׳¨
    const mailOptions = {
      from: session.email,
      to: draft.originalEmail.from,
      subject: draft.subject.startsWith('Re: ') ? draft.subject : `Re: ${draft.subject}`,
      html: `<div dir="auto"><pre style="font-family: sans-serif; white-space: pre-wrap;">${draft.draftContent}</pre></div>`,
      inReplyTo: draft.originalEmail.messageId || undefined,
      references: draft.originalEmail.messageId ? [draft.originalEmail.messageId] : undefined,
      headers: {
        'Content-Type': 'text/html; charset=UTF-8',
        'Content-Transfer-Encoding': 'base64'
      }
    };
    
    const info = await transporter.sendMail(mailOptions);
    
    // ׳׳—׳§ ׳׳× ׳”׳˜׳™׳•׳˜׳” ׳׳—׳¨׳™ ׳”׳©׳׳™׳—׳”
    const filteredDrafts = userDrafts.filter(d => d.id !== draftId);
    drafts.set(session.email, filteredDrafts);
    
    res.json({ 
      success: true, 
      messageId: info.messageId,
      message: '׳”׳×׳©׳•׳‘׳” ׳ ׳©׳׳—׳” ׳‘׳”׳¦׳׳—׳”!' 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: '׳©׳’׳™׳׳” ׳‘׳©׳׳™׳—׳× ׳”׳×׳©׳•׳‘׳”: ' + error.message 
    });
  }
});


// ============= SETTINGS API - ׳©׳׳™׳¨׳× ׳”׳’׳“׳¨׳•׳× ׳׳•׳¦׳₪׳ ׳•׳× =============
const SETTINGS_FILE = path.join(__dirname, 'settings.encrypted');
const ALGORITHM = 'aes-256-gcm';

// ׳₪׳•׳ ׳§׳¦׳™׳•׳× ׳”׳¦׳₪׳ ׳”
function encryptSettings(settings, masterPassword) {
  const salt = crypto.randomBytes(32);
  const key = crypto.pbkdf2Sync(masterPassword, salt, 100000, 32, 'sha256');
  const iv = crypto.randomBytes(16);
  
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  
  let encrypted = cipher.update(JSON.stringify(settings), 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag();
  
  return {
    salt: salt.toString('hex'),
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex'),
    encrypted
  };
}

function decryptSettings(encryptedData, masterPassword) {
  try {
    const salt = Buffer.from(encryptedData.salt, 'hex');
    const key = crypto.pbkdf2Sync(masterPassword, salt, 100000, 32, 'sha256');
    const iv = Buffer.from(encryptedData.iv, 'hex');
    const authTag = Buffer.from(encryptedData.authTag, 'hex');
    
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return JSON.parse(decrypted);
  } catch (error) {
    throw new Error('Invalid master password');
  }
}

// ׳©׳׳™׳¨׳× ׳”׳’׳“׳¨׳•׳×
app.post('/api/settings/save', async (req, res) => {
  try {
    const { settings, masterPassword } = req.body;
    
    if (!masterPassword || masterPassword.length < 8) {
      return res.status(400).json({ 
        error: '׳¡׳™׳¡׳׳× ׳׳׳¡׳˜׳¨ ׳—׳™׳™׳‘׳× ׳׳”׳™׳•׳× ׳׳₪׳—׳•׳× 8 ׳×׳•׳•׳™׳' 
      });
    }
    
    const encrypted = encryptSettings(settings, masterPassword);
    await fs.writeFile(SETTINGS_FILE, JSON.stringify(encrypted, null, 2));
    
    res.json({ success: true });
  } catch (error) {
    console.error('Save settings error:', error);
    res.status(500).json({ error: '׳©׳’׳™׳׳” ׳‘׳©׳׳™׳¨׳× ׳”׳’׳“׳¨׳•׳×' });
  }
});

// ׳˜׳¢׳™׳ ׳× ׳”׳’׳“׳¨׳•׳×
app.post('/api/settings/load', async (req, res) => {
  try {
    const { masterPassword } = req.body;
    
    // ׳‘׳“׳•׳§ ׳׳ ׳§׳™׳™׳ ׳§׳•׳‘׳¥ ׳”׳’׳“׳¨׳•׳×
    try {
      await fs.access(SETTINGS_FILE);
    } catch {
      return res.json({ settings: null, exists: false });
    }
    
    const encryptedData = JSON.parse(await fs.readFile(SETTINGS_FILE, 'utf8'));
    const settings = decryptSettings(encryptedData, masterPassword);
    
    res.json({ settings, exists: true });
  } catch (error) {
    if (error.message.includes('Invalid master password')) {
      res.status(401).json({ error: '׳¡׳™׳¡׳׳× ׳׳׳¡׳˜׳¨ ׳©׳’׳•׳™׳”' });
    } else {
      res.status(500).json({ error: '׳©׳’׳™׳׳” ׳‘׳˜׳¢׳™׳ ׳× ׳”׳’׳“׳¨׳•׳×' });
    }
  }
});

// ׳‘׳“׳•׳§ ׳׳ ׳§׳™׳™׳׳•׳× ׳”׳’׳“׳¨׳•׳×
app.get('/api/settings/exists', async (req, res) => {
  try {
    await fs.access(SETTINGS_FILE);
    res.json({ exists: true });
  } catch {
    res.json({ exists: false });
  }
});

// ============= AUTO-REPLY SYSTEM - ׳׳¢׳¨׳›׳× ׳×׳©׳•׳‘׳” ׳׳•׳˜׳•׳׳˜׳™׳× =============

// Map to track processed emails and reply counts
const processedEmails = new Map(); // email -> Set of messageIds that were processed
const dailyReplyCounts = new Map(); // email -> { date: string, count: number }
const autoReplyIntervals = new Map(); // sessionId -> intervalId

// Helper function to check if email should get auto-reply
function shouldAutoReply(email, settings, userEmail) {
  if (!settings || !settings.autoReplyEnabled) {
    return { shouldReply: false, reason: 'Auto-reply disabled' };
  }

  // Check time restrictions
  if (settings.autoReplyOnlyWorkHours) {
    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentTime = currentHour * 60 + currentMinute;
    
    const startTime = settings.autoReplyWorkStart.split(':');
    const endTime = settings.autoReplyWorkEnd.split(':');
    const workStart = parseInt(startTime[0]) * 60 + parseInt(startTime[1]);
    const workEnd = parseInt(endTime[0]) * 60 + parseInt(endTime[1]);
    
    const currentDay = now.getDay(); // 0 = Sunday, 1 = Monday...
    const workDays = settings.autoReplyWorkDays || [1, 2, 3, 4, 5];
    
    if (!workDays.includes(currentDay)) {
      return { shouldReply: false, reason: 'Outside work days' };
    }
    
    if (currentTime < workStart || currentTime > workEnd) {
      return { shouldReply: false, reason: 'Outside work hours' };
    }
  }

  // Check daily limit
  const today = new Date().toDateString();
  const dailyCount = dailyReplyCounts.get(userEmail);
  if (dailyCount && dailyCount.date === today && dailyCount.count >= (settings.autoReplyMaxPerDay || 5)) {
    return { shouldReply: false, reason: 'Daily limit reached' };
  }

  // Check if already replied to this sender
  if (settings.autoReplyNoRepeat) {
    const processed = processedEmails.get(userEmail) || new Set();
    const senderKey = `${email.from}_today_${today}`;
    if (processed.has(senderKey)) {
      return { shouldReply: false, reason: 'Already replied to this sender today' };
    }
  }

  // Check blacklist
  if (settings.autoReplyBlacklist) {
    const blacklist = settings.autoReplyBlacklist.split(/[,\n\r]/).map(addr => addr.trim().toLowerCase()).filter(addr => addr.length > 0);
    if (blacklist.some(blocked => email.from.toLowerCase().includes(blocked))) {
      return { shouldReply: false, reason: 'Sender in blacklist' };
    }
  }

  // Check whitelist (if not empty)
  if (settings.autoReplyWhitelist && settings.autoReplyWhitelist.trim()) {
    const whitelist = settings.autoReplyWhitelist.split(/[,\n\r]/).map(addr => addr.trim().toLowerCase()).filter(addr => addr.length > 0);
    if (!whitelist.some(allowed => email.from.toLowerCase().includes(allowed))) {
      return { shouldReply: false, reason: 'Sender not in whitelist' };
    }
  }

  // Check for automated emails
  if (settings.autoReplyExcludeAutomated) {
    const automatedPatterns = [
      'noreply', 'no-reply', 'donotreply', 'do-not-reply',
      'automated', 'automatic', 'robot', 'bot@',
      'notification', 'alerts', 'system@'
    ];
    
    if (automatedPatterns.some(pattern => email.from.toLowerCase().includes(pattern))) {
      return { shouldReply: false, reason: 'Automated email detected' };
    }

    // Check subject for automated patterns
    const automatedSubjects = ['automated', 'auto:', '[auto]', 'notification', 'alert:', 'system:'];
    if (automatedSubjects.some(pattern => email.subject.toLowerCase().includes(pattern))) {
      return { shouldReply: false, reason: 'Automated email subject detected' };
    }
  }

  // Check if message ID already processed
  if (email.messageId) {
    const processed = processedEmails.get(userEmail) || new Set();
    if (processed.has(email.messageId)) {
      return { shouldReply: false, reason: 'Message already processed' };
    }
  }

  return { shouldReply: true, reason: 'All checks passed' };
}

// Function to create auto-reply
async function createAutoReply(email, session, settings) {
  try {
    console.log(`[AUTO-REPLY] Creating auto-reply for email from ${email.from}`);

    // Prepare email content for AI
    const emailContent = {
      from: email.from,
      from_name: email.from_name || email.from,
      subject: email.subject,
      body: email.body,
      date: email.date
    };

    // Get Claude API key
    const apiKey = session.claudeApiKey || process.env.CLAUDE_API_KEY;
    if (!apiKey) {
      console.error('[AUTO-REPLY] No Claude API key available');
      return { success: false, error: 'No API key' };
    }

    // Create AI settings based on user preferences
    const aiSettings = {
      tone: settings.autoReplyTone || 'professional',
      maxLength: settings.autoReplyLength === 'short' ? 200 : settings.autoReplyLength === 'long' ? 800 : 500,
      creativity: settings.autoReplyCreativity || 0.7
    };

    // Call the existing smart reply endpoint logic
    const baseSystemPrompt = '׳׳×׳” ׳¢׳•׳–׳¨ ׳“׳•׳׳¨ ׳׳׳§׳˜׳¨׳•׳ ׳™ ׳©׳›׳•׳×׳‘ ׳×׳©׳•׳‘׳•׳× ׳׳§׳¦׳•׳¢׳™׳•׳× ׳׳ ׳™׳“׳™׳“׳•׳×׳™׳•׳×. ׳”׳×׳׳ ׳׳× ׳”׳©׳₪׳” ׳׳©׳₪׳× ׳”׳׳™׳™׳ ׳”׳׳§׳•׳¨׳™. ׳–׳•׳”׳™ ׳×׳©׳•׳‘׳” ׳׳•׳˜׳•׳׳˜׳™׳× - ׳”׳™׳” ׳§׳¦׳¨ ׳•׳׳“׳•׳™׳§.';
    
    let fullEmailContent = `׳׳׳×: ${emailContent.from}\n`;
    fullEmailContent += `׳ ׳•׳©׳: ${emailContent.subject}\n`;
    fullEmailContent += `׳×׳׳¨׳™׳: ${emailContent.date}\n\n`;
    fullEmailContent += `׳×׳•׳›׳ ׳”׳׳™׳™׳:\n${emailContent.body}`;

    const response = await axios.post('https://api.anthropic.com/v1/messages', {
      model: 'claude-3-haiku-20240307',
      max_tokens: aiSettings.maxLength,
      temperature: aiSettings.creativity,
      messages: [
        {
          role: 'user',
          content: `׳›׳×׳•׳‘ ׳×׳©׳•׳‘׳” ${aiSettings.tone === 'formal' ? '׳₪׳•׳¨׳׳׳™׳×' : aiSettings.tone === 'friendly' ? '׳™׳“׳™׳“׳•׳×׳™׳×' : '׳׳§׳¦׳•׳¢׳™׳×'} ׳׳׳™׳™׳ ׳”׳–׳”.

׳—׳©׳•׳‘ ׳׳׳•׳“: 
1. ׳–׳•׳”׳™ ׳×׳©׳•׳‘׳” ׳׳•׳˜׳•׳׳˜׳™׳× - ׳”׳™׳” ׳§׳¦׳¨ ׳•׳׳¢׳ ׳™׳™׳
2. ׳₪׳¨׳§ ׳׳× ׳”׳×׳©׳•׳‘׳” ׳׳₪׳™׳¡׳§׳׳•׳× ׳ ׳₪׳¨׳“׳•׳× ׳¢׳ ׳©׳•׳¨׳•׳× ׳¨׳™׳§׳•׳× ׳‘׳™׳ ׳™׳”׳
3. ׳”׳×׳—׳ ׳‘׳‘׳¨׳›׳” ׳•׳”׳¡׳×׳™׳™׳ ׳‘׳—׳×׳™׳׳” ׳׳§׳¦׳•׳¢׳™׳×
4. ׳¦׳™׳™׳ ׳©׳–׳•׳”׳™ ׳×׳©׳•׳‘׳” ׳׳•׳˜׳•׳׳˜׳™׳× ׳•׳›׳™ ׳×׳×׳§׳‘׳ ׳×׳©׳•׳‘׳” ׳׳₪׳•׳¨׳˜׳× ׳‘׳”׳׳©׳

׳”׳׳™׳™׳ ׳׳׳¢׳ ׳”:
${fullEmailContent}`
        }
      ],
      system: baseSystemPrompt
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      }
    });

    const replyContent = response.data.content[0].text;
    
    // Create draft using existing draft save logic
    const subject = email.subject.startsWith('Re: ') ? email.subject : `Re: ${email.subject}`;
    
    // Save the auto-reply as a draft
    const draftId = Math.random().toString(36).substring(7);
    const draft = {
      id: draftId,
      userEmail: session.email,
      originalEmail: emailContent,
      draftContent: replyContent,
      subject: subject,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      savedInGmail: false,
      isAutoReply: true
    };

    // Save locally
    if (!drafts.has(session.email)) {
      drafts.set(session.email, []);
    }
    drafts.get(session.email).push(draft);

    // Try to save to Gmail as well
    try {
      await saveAutoReplyToGmail(draft, session, replyContent);
      draft.savedInGmail = true;
    } catch (gmailError) {
      console.error('[AUTO-REPLY] Failed to save to Gmail:', gmailError.message);
    }

    // Mark as processed
    const processed = processedEmails.get(session.email) || new Set();
    if (email.messageId) {
      processed.add(email.messageId);
    }
    
    // Add sender to processed (for no-repeat feature)
    if (settings.autoReplyNoRepeat) {
      const today = new Date().toDateString();
      processed.add(`${email.from}_today_${today}`);
    }
    
    processedEmails.set(session.email, processed);

    // Update daily count
    const today = new Date().toDateString();
    const dailyCount = dailyReplyCounts.get(session.email);
    if (!dailyCount || dailyCount.date !== today) {
      dailyReplyCounts.set(session.email, { date: today, count: 1 });
    } else {
      dailyCount.count++;
    }

    console.log(`[AUTO-REPLY] Successfully created auto-reply draft for ${email.from}`);
    return { success: true, draftId, replyContent };

  } catch (error) {
    console.error('[AUTO-REPLY] Error creating auto-reply:', error.message);
    return { success: false, error: error.message };
  }
}

// Function to save auto-reply to Gmail
async function saveAutoReplyToGmail(draft, session, replyContent) {
  const imap = createImapConnection(
    session.email, 
    session.password, 
    session.imap.server, 
    session.imap.port
  );

  return new Promise((resolve, reject) => {
    const messageDate = new Date().toUTCString();
    const toEmail = draft.originalEmail.from;
    const draftSubject = `[׳׳׳×׳™׳ ׳׳©׳׳™׳—׳” - ׳×׳©׳•׳‘׳” ׳׳•׳˜׳•׳׳˜׳™׳×] ${draft.subject}`;
    
    // Format content professionally (using existing logic)
    let formattedContent = replyContent;
    
    if (!formattedContent.includes('<html>') && !formattedContent.includes('<div>')) {
      let paragraphs = formattedContent.split('\n').map(line => line.trim()).filter(line => line.length > 0);
      
      if (paragraphs.length <= 2 && formattedContent.length > 100) {
        const intelligentSplit = formattedContent
          .replace(/(\.)(\s+)([A-Z\u0590-\u05FF])/g, '$1\n\n$3')
          .replace(/(\?)(\s+)([A-Z\u0590-\u05FF])/g, '$1\n\n$3')
          .replace(/(\!)(\s+)([A-Z\u0590-\u05FF])/g, '$1\n\n$3')
          .replace(/(׳©׳׳•׳[^,]*,)(\s*)/g, '$1\n\n')
          .replace(/(׳×׳•׳“׳”[^.]*\.)(\s+)/g, '$1\n\n')
          .replace(/(׳‘׳‘׳¨׳›׳”[^,]*,?)(\s*)/g, '\n\n$1\n\n');
        
        paragraphs = intelligentSplit.split('\n').map(line => line.trim()).filter(line => line.length > 0);
      }
      
      formattedContent = paragraphs
        .map(paragraph => `<p style="margin: 0 0 12px 0; line-height: 1.5;">${paragraph}</p>`)
        .join('');
      
      formattedContent = `
<!DOCTYPE html>
<html dir="rtl" lang="he">
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; font-size: 14px; line-height: 1.6; color: #333; direction: rtl; text-align: right; margin: 0; padding: 20px; }
        .email-content { max-width: 600px; margin: 0 auto; }
        p { margin: 0 0 12px 0; line-height: 1.5; }
        .auto-reply-notice { margin-top: 20px; padding: 10px; background-color: #f0f8ff; border: 1px solid #d1ecf1; border-radius: 5px; font-size: 12px; color: #0c5460; }
    </style>
</head>
<body>
    <div class="email-content">
        ${formattedContent}
        <div class="auto-reply-notice">
            <p><strong>נ₪– ׳”׳•׳“׳¢׳” ׳–׳• ׳ ׳•׳¦׳¨׳” ׳׳•׳˜׳•׳׳˜׳™׳× ׳¢׳ ׳™׳“׳™ ׳׳¢׳¨׳›׳× ׳×׳©׳•׳‘׳” ׳—׳›׳׳”</strong><br>
            ׳ ׳•׳¦׳¨׳”: ${new Date().toLocaleString('he-IL')}</p>
        </div>
    </div>
</body>
</html>`;
    }
    
    const draftMessage = `From: ${session.email}\r\n` +
                          `To: ${toEmail}\r\n` +
                          `Subject: ${draftSubject}\r\n` +
                          `Date: ${messageDate}\r\n` +
                          `MIME-Version: 1.0\r\n` +
                          `Content-Type: text/html; charset=UTF-8\r\n` +
                          `Content-Transfer-Encoding: 8bit\r\n` +
                          `References: ${draft.originalEmail.messageId || ''}\r\n` +
                          `In-Reply-To: ${draft.originalEmail.messageId || ''}\r\n` +
                          `\r\n` +
                          `${formattedContent}`;

    imap.once('ready', () => {
      imap.append(draftMessage, { 
        mailbox: '[Gmail]/Drafts', 
        flags: ['\\Draft'] 
      }, (err) => {
        imap.end();
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });

    imap.once('error', (err) => {
      reject(err);
    });

    imap.connect();
  });
}

// Function to monitor new emails for a user
async function monitorNewEmails(session) {
  if (!session || !session.autoReplySettings || !session.autoReplySettings.autoReplyEnabled) {
    return;
  }

  try {
    console.log(`[AUTO-REPLY] Monitoring new emails for ${session.email}`);
    
    const imap = createImapConnection(
      session.email, 
      session.password, 
      session.imap.server, 
      session.imap.port
    );

    imap.once('ready', () => {
      imap.openBox('INBOX', true, (err, box) => {
        if (err) {
          console.error(`[AUTO-REPLY] Error opening inbox for ${session.email}:`, err);
          return;
        }

        // Get recent emails (last 5 to avoid overwhelming)
        const total = box.messages.total;
        if (total === 0) return;

        const start = Math.max(1, total - 4); // Get last 5 emails
        const fetch = imap.seq.fetch(`${start}:${total}`, {
          bodies: '',
          struct: true,
          envelope: true
        });

        fetch.on('message', (msg, seqno) => {
          const email = { 
            id: seqno.toString(),
            from: '',
            from_name: '',
            subject: '',
            body: '',
            date: new Date().toISOString(),
            messageId: null
          };

          let headerData = false;
          let bodyData = false;
          const chunks = [];

          const checkComplete = () => {
            if (headerData && bodyData) {
              // Check if this email should get an auto-reply
              const shouldReplyResult = shouldAutoReply(email, session.autoReplySettings, session.email);
              
              if (shouldReplyResult.shouldReply) {
                console.log(`[AUTO-REPLY] Email from ${email.from} qualifies for auto-reply`);
                createAutoReply(email, session, session.autoReplySettings);
              } else {
                console.log(`[AUTO-REPLY] Skipping email from ${email.from}: ${shouldReplyResult.reason}`);
              }
            }
          };

          msg.on('body', (stream, info) => {
            stream.on('data', (chunk) => {
              chunks.push(chunk);
            });

            stream.on('end', async () => {
              try {
                const buffer = Buffer.concat(chunks);
                const parsed = await simpleParser(buffer);
                
                if (info.which === 'HEADER' || info.which.includes('HEADER')) {
                  email.from = parsed.from?.value?.[0]?.address || 'Unknown';
                  email.from_name = parsed.from?.value?.[0]?.name || parsed.from?.value?.[0]?.address || 'Unknown';
                  email.subject = parsed.subject || '(׳׳׳ ׳ ׳•׳©׳)';
                  email.date = parsed.date ? parsed.date.toISOString() : new Date().toISOString();
                  email.messageId = parsed.messageId || null;
                  headerData = true;
                } else {
                  email.body = parsed.html || parsed.text || buffer.toString();
                  bodyData = true;
                }
                
                checkComplete();
              } catch (e) {
                console.error(`[AUTO-REPLY] Error parsing email:`, e);
                headerData = true;
                bodyData = true;
                checkComplete();
              }
            });
          });

          msg.once('attributes', (attrs) => {
            // Additional email metadata if needed
          });
        });

        fetch.once('end', () => {
          imap.end();
        });
      });
    });

    imap.once('error', (err) => {
      console.error(`[AUTO-REPLY] IMAP error for ${session.email}:`, err);
    });

    imap.connect();

  } catch (error) {
    console.error(`[AUTO-REPLY] Error monitoring emails for ${session.email}:`, error);
  }
}

// API endpoint to get auto-reply settings
app.get('/api/auto-reply/settings', (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  res.json(session.autoReplySettings || {});
});

// API endpoint to save auto-reply settings
app.post('/api/auto-reply/settings', (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  session.autoReplySettings = req.body;
  
  // Also get Claude API key from localStorage if it exists
  const claudeApiKey = req.headers['x-claude-api-key'];
  if (claudeApiKey) {
    session.claudeApiKey = claudeApiKey;
    console.log(`[AUTO-REPLY] Claude API key updated for ${session.email}`);
  }
  
  // Start or stop monitoring based on settings
  if (req.body.autoReplyEnabled) {
    console.log(`[AUTO-REPLY] Enabling auto-reply for ${session.email}`);
    console.log(`[AUTO-REPLY] Settings:`, JSON.stringify(req.body, null, 2));
    
    // Check if Claude API key is available
    if (!session.claudeApiKey && !process.env.CLAUDE_API_KEY) {
      console.log(`[AUTO-REPLY] WARNING: No Claude API key available for ${session.email}`);
    } else {
      console.log(`[AUTO-REPLY] Claude API key is available for ${session.email}`);
    }
    
    // Stop existing monitoring if any
    if (autoReplyIntervals.has(sessionId)) {
      clearInterval(autoReplyIntervals.get(sessionId));
      console.log(`[AUTO-REPLY] Stopped existing monitoring for ${session.email}`);
    }
    
    // Start monitoring every 2 minutes
    const intervalId = setInterval(() => {
      console.log(`[AUTO-REPLY] Checking for new emails for ${session.email}...`);
      monitorNewEmails(session);
    }, 2 * 60 * 1000); // 2 minutes
    
    autoReplyIntervals.set(sessionId, intervalId);
    console.log(`[AUTO-REPLY] Started monitoring for ${session.email} (checking every 2 minutes)`);
    
    // Also run an immediate check
    console.log(`[AUTO-REPLY] Running immediate check for ${session.email}...`);
    setTimeout(() => {
      monitorNewEmails(session);
    }, 5000); // 5 seconds delay
    
  } else {
    // Stop monitoring
    if (autoReplyIntervals.has(sessionId)) {
      clearInterval(autoReplyIntervals.get(sessionId));
      autoReplyIntervals.delete(sessionId);
      console.log(`[AUTO-REPLY] Stopped monitoring for ${session.email}`);
    }
  }
  
  res.json({ success: true, message: '׳”׳’׳“׳¨׳•׳× ׳ ׳©׳׳¨׳• ׳‘׳”׳¦׳׳—׳”' });
});

// API endpoint to get auto-reply statistics
app.get('/api/auto-reply/stats', (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(401).json({ error: '׳׳ ׳׳—׳•׳‘׳¨' });
  }
  
  const today = new Date().toDateString();
  const dailyCount = dailyReplyCounts.get(session.email);
  const todayCount = (dailyCount && dailyCount.date === today) ? dailyCount.count : 0;
  
  const userDrafts = drafts.get(session.email) || [];
  const autoReplyDrafts = userDrafts.filter(d => d.isAutoReply);
  
  res.json({
    todayCount,
    totalAutoReplyDrafts: autoReplyDrafts.length,
    isMonitoring: autoReplyIntervals.has(sessionId),
    lastCheck: new Date().toISOString()
  });
});

const PORT = 4000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log('Ready to connect to real email accounts!');
  console.log('Claude AI integration enabled!');
});
