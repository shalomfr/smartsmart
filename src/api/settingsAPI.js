// Settings API - ׳©׳׳™׳¨׳” ׳•׳˜׳¢׳™׳ ׳” ׳©׳ ׳”׳’׳“׳¨׳•׳× ׳׳”׳©׳¨׳×

const API_URL = 'http://31.97.129.5:4000http://31.97.129.5:4000http://31.97.129.5:4000/api';

// ׳‘׳“׳•׳§ ׳׳ ׳§׳™׳™׳׳•׳× ׳”׳’׳“׳¨׳•׳× ׳©׳׳•׳¨׳•׳×
export const checkSettingsExist = async () => {
  try {
    const response = await fetch(`http://31.97.129.5:4000http://31.97.129.5:4000http://31.97.129.5:4000/api/settings/exists`);
    const data = await response.json();
    return data.exists;
  } catch (error) {
    console.error('Error checking settings:', error);
    return false;
  }
};

// ׳©׳׳•׳¨ ׳”׳’׳“׳¨׳•׳×
export const saveSettings = async (settings, masterPassword) => {
  try {
    const response = await fetch(`http://31.97.129.5:4000http://31.97.129.5:4000http://31.97.129.5:4000/api/settings/save`, {
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

// ׳˜׳¢׳ ׳”׳’׳“׳¨׳•׳×
export const loadSettings = async (masterPassword) => {
  try {
    const response = await fetch(`http://31.97.129.5:4000http://31.97.129.5:4000http://31.97.129.5:4000/api/settings/load`, {
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
