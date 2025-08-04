// Claude AI API Integration

const API_URL = 'http://localhost:3001/api';

// Get API key from localStorage
const getClaudeApiKey = () => localStorage.getItem('claudeApiKey');

// הגדרות AI מותאמות אישית
const getAISettings = () => {
  const settings = localStorage.getItem('aiTrainingSettings');
  if (settings) {
    const parsed = JSON.parse(settings);
    return {
      tone: parsed.tone || 'professional',
      language: parsed.language || 'auto',
      creativity: parsed.creativity || 0.7,
      maxLength: parsed.maxLength || 500,
      includeContext: parsed.includeContext ?? true,
      autoCorrect: parsed.autoCorrect ?? true
    };
  }
  return {
    tone: 'professional',
    language: 'auto',
    creativity: 0.7,
    maxLength: 500,
    includeContext: true,
    autoCorrect: true
  };
};

// Claude API call helper
export const claudeAPI = async (prompt, system = '') => {
  const apiKey = getClaudeApiKey();
  
  if (!apiKey) {
    throw new Error('לא הוגדר מפתח API של Claude. אנא הגדר בהגדרות.');
  }

  // שלב את ה-system prompt המותאם אישית
  const customSystemPrompt = localStorage.getItem('claudeSystemPrompt');
  const finalSystemPrompt = customSystemPrompt ? 
    `${customSystemPrompt}\n\n${system}` : system;

  try {
    const response = await fetch(`${API_URL}/claude/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        prompt,
        system: finalSystemPrompt,
        apiKey
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'שגיאה בקריאה ל-Claude API');
    }

    const data = await response.json();
    return data.text;
  } catch (error) {
    console.error('Claude API Error:', error);
    throw error;
  }
};

// פונקציות עזר לפיצ'רים ספציפיים
export const generateSmartReply = async (emailContent) => {
  const apiKey = getClaudeApiKey();
  
  if (!apiKey) {
    throw new Error('לא הוגדר מפתח API של Claude. אנא הגדר בהגדרות.');
  }

  const settings = getAISettings();
  const customSystemPrompt = localStorage.getItem('claudeSystemPrompt');

  try {
    const response = await fetch(`${API_URL}/claude/smart-reply`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        emailContent,
        apiKey,
        settings,
        customSystemPrompt
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'שגיאה ביצירת תשובה חכמה');
    }

    const data = await response.json();
    return data.reply;
  } catch (error) {
    console.error('Smart Reply Error:', error);
    throw error;
  }
};

export const generateSubject = async (emailBody) => {
  const apiKey = getClaudeApiKey();
  
  if (!apiKey) {
    throw new Error('לא הוגדר מפתח API של Claude. אנא הגדר בהגדרות.');
  }

  const settings = getAISettings();
  const customSystemPrompt = localStorage.getItem('claudeSystemPrompt');

  try {
    const response = await fetch(`${API_URL}/claude/generate-subject`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        emailBody,
        apiKey,
        settings,
        customSystemPrompt
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'שגיאה ביצירת כותרת');
    }

    const data = await response.json();
    return data.subject;
  } catch (error) {
    console.error('Generate Subject Error:', error);
    throw error;
  }
};

export const improveEmail = async (emailContent, style) => {
  const apiKey = getClaudeApiKey();
  
  if (!apiKey) {
    throw new Error('לא הוגדר מפתח API של Claude. אנא הגדר בהגדרות.');
  }

  const settings = getAISettings();
  const customSystemPrompt = localStorage.getItem('claudeSystemPrompt');

  try {
    const response = await fetch(`${API_URL}/claude/improve-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        emailContent,
        style,
        apiKey,
        settings,
        customSystemPrompt
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'שגיאה בשיפור המייל');
    }

    const data = await response.json();
    return data.improved;
  } catch (error) {
    console.error('Improve Email Error:', error);
    throw error;
  }
};