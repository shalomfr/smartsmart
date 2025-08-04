// Settings API - שמירה וטעינה של הגדרות מהשרת

const API_URL = '/api';

// בדוק אם קיימות הגדרות שמורות
export const checkSettingsExist = async () => {
  try {
    const response = await fetch(`${API_URL}/settings/exists`);
    const data = await response.json();
    return data.exists;
  } catch (error) {
    console.error('Error checking settings:', error);
    return false;
  }
};

// שמור הגדרות
export const saveSettings = async (settings, masterPassword) => {
  try {
    const response = await fetch(`${API_URL}/settings/save`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ settings, masterPassword })
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to save settings');
    }
    
    return await response.json();
  } catch (error) {
    throw error;
  }
};

// טען הגדרות
export const loadSettings = async (masterPassword) => {
  try {
    const response = await fetch(`${API_URL}/settings/load`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ masterPassword })
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Failed to load settings');
    }
    
    return await response.json();
  } catch (error) {
    throw error;
  }
};