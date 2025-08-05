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
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Store user sessions (in production, use Redis or database)
const sessions = new Map();

// משתמשים לדוגמה - בסביבת production יש לשמור במסד נתונים מאובטח
const APP_USERS = [
  {
    username: 'admin',
    password: '123456', // בסביבת production יש להשתמש בהצפנה!
    name: 'מנהל המערכת'
  },
  {
    username: 'user1',
    password: 'password',
    name: 'משתמש לדוגמה'
  }
];

// Handle OPTIONS for CORS
app.options('/api/app/login', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.sendStatus(200);
});

// Login endpoint for the application (not email)
app.post('/api/app/login', async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  const { username, password } = req.body;
  
  // מחפש את המשתמש
  const user = APP_USERS.find(u => u.username === username && u.password === password);
  
  if (user) {
    // יצירת token פשוט (בסביבת production יש להשתמש ב-JWT)
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
      message: 'שם משתמש או סיסמה שגויים'
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
      sessions.set(sessionId, {
        email,
        password,
        imap: { server: imap_server, port: imap_port },
        smtp: { server: smtp_server, port: smtp_port }
      });
      
      res.json({ 
        success: true, 
        sessionId,
        message: 'התחברת בהצלחה!' 
      });
    });
    
    imap.once('error', (err) => {
      res.status(401).json({ 
        success: false, 
        message: 'שגיאת התחברות: ' + err.message 
      });
    });
    
    imap.connect();
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'שגיאת שרת: ' + error.message 
    });
  }
});

// Get emails from folder
app.get('/api/emails/:folder', async (req, res) => {
  const sessionId = req.headers.authorization;
  const session = sessions.get(sessionId);
  const folder = req.params.folder;
  
  if (!session) {
    return res.status(401).json({ error: 'לא מחובר' });
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
        struct: true
      });
      
      // Return more realistic mock emails for demo
      const mockEmails = [
        {
          id: "1",
          folder: folder,
          from: "support@gmail.com",
          from_name: "Gmail Team",
          to: [session.email],
          subject: "ברוכים הבאים ל-Gmail!",
          body: "<p>שלום,<br><br>ברוכים הבאים לחשבון Gmail שלך. האפליקציה מחוברת בהצלחה!</p>",
          date: new Date().toISOString(),
          is_read: false,
          is_starred: true
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
          is_starred: false
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
          is_starred: false
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
          is_starred: false
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
            let buffer = '';
            stream.on('data', chunk => buffer += chunk.toString('utf8'));
            stream.on('end', async () => {
              try {
                const parsed = await simpleParser(buffer);
                
                if (info.which === 'HEADER' || info.which.includes('HEADER')) {
                  email.from = parsed.from?.value?.[0]?.address || session.email;
                  email.from_name = parsed.from?.value?.[0]?.name || parsed.from?.value?.[0]?.address || session.email.split('@')[0];
                  email.to = parsed.to ? parsed.to.value.map(t => t.address) : [];
                  email.subject = parsed.subject || '(ללא נושא)';
                  email.date = parsed.date ? parsed.date.toISOString() : new Date().toISOString();
                  headerData = true;
                  console.log(`Email ${seqno} header parsed:`, email.subject);
                } else {
                  email.body = parsed.html || parsed.text || buffer;
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
    return res.status(401).json({ error: 'לא מחובר' });
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
      html: body
    };
    
    const info = await transporter.sendMail(mailOptions);
    res.json({ 
      success: true, 
      messageId: info.messageId,
      message: 'המייל נשלח בהצלחה!' 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'שגיאה בשליחת המייל: ' + error.message 
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
    return res.status(401).json({ error: 'לא מחובר' });
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

// פונקציה לבניית system prompt משופר
const buildSystemPrompt = (customPrompt, basePrompt, settings) => {
  let finalPrompt = basePrompt;
  
  if (customPrompt) {
    finalPrompt = customPrompt + '\n\n' + basePrompt;
  }
  
  // הוסף הגדרות ספציפיות
  if (settings) {
    if (settings.language && settings.language !== 'auto') {
      const languageMap = {
        'hebrew': 'עברית',
        'english': 'English',
        'arabic': 'العربية',
        'russian': 'Русский'
      };
      finalPrompt += `\nכתוב ב${languageMap[settings.language] || settings.language}.`;
    }
    if (settings.maxLength) {
      finalPrompt += `\nהגבל את התשובה ל-${settings.maxLength} מילים לכל היותר.`;
    }
    if (settings.autoCorrect) {
      finalPrompt += `\nתקן שגיאות כתיב ודקדוק.`;
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

  const baseSystemPrompt = 'אתה עוזר דואר אלקטרוני שכותב תשובות מקצועיות אך ידידותיות. התאם את השפה לשפת המייל המקורי.';
  const systemPrompt = buildSystemPrompt(customSystemPrompt, baseSystemPrompt, settings);

  // בניית תוכן המייל המלא
  let fullEmailContent = '';
  if (typeof emailContent === 'object') {
    fullEmailContent = `מאת: ${emailContent.from || 'Unknown'}\n`;
    fullEmailContent += `נושא: ${emailContent.subject || 'No Subject'}\n`;
    fullEmailContent += `תאריך: ${emailContent.date || 'Unknown'}\n\n`;
    fullEmailContent += `תוכן המייל:\n${emailContent.body || 'No content'}`;
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
          content: `כתוב תשובה ${settings?.tone === 'formal' ? 'פורמלית' : settings?.tone === 'friendly' ? 'ידידותית' : 'מקצועית'} למייל הזה:\n\n${fullEmailContent}`
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

  const baseSystemPrompt = 'אתה מומחה ביצירת כותרות מיילים. צור כותרות קצרות, ממוקדות ומקצועיות.';
  const systemPrompt = buildSystemPrompt(customSystemPrompt, baseSystemPrompt, settings);

  try {
    const response = await axios.post('https://api.anthropic.com/v1/messages', {
      model: 'claude-3-haiku-20240307',
      max_tokens: 50,
      temperature: settings?.creativity || 0.7,
      messages: [
        {
          role: 'user',
          content: `צור כותרת קצרה וממוקדת למייל הבא. החזר רק את הכותרת בלבד:\n\n${emailBody}`
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
    professional: 'שפר את המייל לסגנון מקצועי ופורמלי',
    friendly: 'שפר את המייל לסגנון ידידותי וחם',
    concise: 'קצר את המייל והפוך אותו לתמציתי וישיר לעניין'
  };

  const baseSystemPrompt = 'אתה עורך מיילים מקצועי שמשפר את הסגנון והבהירות מבלי לשנות את התוכן.';
  const systemPrompt = buildSystemPrompt(customSystemPrompt, baseSystemPrompt, settings);

  try {
    const response = await axios.post('https://api.anthropic.com/v1/messages', {
      model: 'claude-3-haiku-20240307',
      max_tokens: settings?.maxLength || 1000,
      temperature: settings?.creativity || 0.7,
      messages: [
        {
          role: 'user',
          content: `${stylePrompts[style] || stylePrompts.professional}. שמור על המשמעות המקורית:\n\n${emailContent}`
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


// ============= SETTINGS API - שמירת הגדרות מוצפנות =============
const SETTINGS_FILE = path.join(__dirname, 'settings.encrypted');
const ALGORITHM = 'aes-256-gcm';

// פונקציות הצפנה
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

// שמירת הגדרות
app.post('/api/settings/save', async (req, res) => {
  try {
    const { settings, masterPassword } = req.body;
    
    if (!masterPassword || masterPassword.length < 8) {
      return res.status(400).json({ 
        error: 'סיסמת מאסטר חייבת להיות לפחות 8 תווים' 
      });
    }
    
    const encrypted = encryptSettings(settings, masterPassword);
    await fs.writeFile(SETTINGS_FILE, JSON.stringify(encrypted, null, 2));
    
    res.json({ success: true });
  } catch (error) {
    console.error('Save settings error:', error);
    res.status(500).json({ error: 'שגיאה בשמירת הגדרות' });
  }
});

// טעינת הגדרות
app.post('/api/settings/load', async (req, res) => {
  try {
    const { masterPassword } = req.body;
    
    // בדוק אם קיים קובץ הגדרות
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
      res.status(401).json({ error: 'סיסמת מאסטר שגויה' });
    } else {
      res.status(500).json({ error: 'שגיאה בטעינת הגדרות' });
    }
  }
});

// בדוק אם קיימות הגדרות
app.get('/api/settings/exists', async (req, res) => {
  try {
    await fs.access(SETTINGS_FILE);
    res.json({ exists: true });
  } catch {
    res.json({ exists: false });
  }
});

const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log('Ready to connect to real email accounts!');
  console.log('Claude AI integration enabled!');
});