import React, { useState, useEffect } from 'react';
import { Button } from '../components/ui/button';
import { Card, CardContent } from '../components/ui/card';
import { Textarea } from '../components/ui/textarea';
import { Trash2, Send, Edit3, Clock, User, Mail, ChevronDown, ChevronUp, CheckCircle, ClipboardCheck } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { realEmailAPI } from '../api/realEmailAPI';
import { toast } from 'sonner';

// פונקציית עזר לפענוח Base64
const decodeBase64 = (str) => {
  try {
    // בדוק אם המחרוזת היא Base64 תקינה
    if (/^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(str)) {
      const decoded = atob(str);
      // ודא שהתוצאה היא טקסט קריא (למשל, מכילה HTML)
      if (decoded.includes('<') && decoded.includes('>')) {
        return decoded;
      }
    }
  } catch (e) {
    // אם הפענוח נכשל, זה לא Base64
  }
  return str; // החזר את המחרוזת המקורית אם היא לא Base64
};


const PendingReplies = () => {
  const [drafts, setDrafts] = useState([]);
  const [expandedDrafts, setExpandedDrafts] = useState({});
  const [editingDrafts, setEditingDrafts] = useState({});
  const [loading, setLoading] = useState(true);

  // טוען את הטיוטות מהשרת
  const loadDrafts = async () => {
    try {
      setLoading(true);
      const sessionId = localStorage.getItem('emailSessionId');
      const response = await fetch(window.location.hostname === 'localhost' ? '/api/drafts' : 'http://31.97.129.5:4000/api/drafts', {
        headers: {
          'Authorization': sessionId
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setDrafts(data);
      }
    } catch (error) {
      console.error('Error loading drafts:', error);
      toast.error('שגיאה בטעינת טיוטות');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDrafts();
  }, []);

  // מחיקת טיוטה
  const deleteDraft = async (draftId) => {
    try {
      const sessionId = localStorage.getItem('emailSessionId');
      const response = await fetch(window.location.hostname === 'localhost' ? `/api/drafts/${draftId}` : `http://31.97.129.5:4000/api/drafts/${draftId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': sessionId
        }
      });

      if (response.ok) {
        toast.success('הטיוטה נמחקה בהצלחה');
        setDrafts(drafts.filter(d => d.id !== draftId));
      } else {
        toast.error('שגיאה במחיקת הטיוטה');
      }
    } catch (error) {
      console.error('Error deleting draft:', error);
      toast.error('שגיאה במחיקת הטיוטה');
    }
  };

  // עדכון טיוטה
  const updateDraft = async (draftId, newContent) => {
    try {
      const sessionId = localStorage.getItem('emailSessionId');
      const response = await fetch(window.location.hostname === 'localhost' ? `/api/drafts/${draftId}` : `http://31.97.129.5:4000/api/drafts/${draftId}`, {
        method: 'PUT',
        headers: {
          'Authorization': sessionId,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ draftContent: newContent })
      });

      if (response.ok) {
        toast.success('הטיוטה עודכנה בהצלחה');
        setDrafts(drafts.map(d => 
          d.id === draftId ? { ...d, draftContent: newContent } : d
        ));
        setEditingDrafts({ ...editingDrafts, [draftId]: false });
      } else {
        toast.error('שגיאה בעדכון הטיוטה');
      }
    } catch (error) {
      console.error('Error updating draft:', error);
      toast.error('שגיאה בעדכון הטיוטה');
    }
  };

  // שליחת טיוטה
  const sendDraft = async (draftId) => {
    try {
      const sessionId = localStorage.getItem('emailSessionId');
      const response = await fetch(window.location.hostname === 'localhost' ? `/api/drafts/${draftId}/send` : `http://31.97.129.5:4000/api/drafts/${draftId}/send`, {
        method: 'POST',
        headers: {
          'Authorization': sessionId
        }
      });

      if (response.ok) {
        toast.success('התשובה נשלחה בהצלחה!');
        setDrafts(drafts.filter(d => d.id !== draftId));
      } else {
        const error = await response.json();
        toast.error(error.message || 'שגיאה בשליחת התשובה');
      }
    } catch (error) {
      console.error('Error sending draft:', error);
      toast.error('שגיאה בשליחת התשובה');
    }
  };

  const toggleExpanded = (draftId) => {
    setExpandedDrafts({
      ...expandedDrafts,
      [draftId]: !expandedDrafts[draftId]
    });
  };

  const toggleEdit = (draftId) => {
    setEditingDrafts({
      ...editingDrafts,
      [draftId]: !editingDrafts[draftId]
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (drafts.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-full text-gray-500">
        <ClipboardCheck className="w-16 h-16 mb-4 text-gray-300" />
        <h2 className="text-xl font-semibold mb-2">אין טיוטות ממתינות</h2>
        <p className="text-sm">כאן יופיעו תשובות חכמות שטרם נשלחו</p>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-4">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">בהמתנה לתשובה</h1>
        <p className="text-gray-600">נהל ושלח תשובות חכמות שנשמרו כטיוטות</p>
      </div>

      <AnimatePresence>
        {drafts.map((draft) => (
          <motion.div
            key={draft.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="mb-4"
          >
            <Card className="shadow-lg hover:shadow-xl transition-shadow duration-300">
              <CardContent className="p-6">
                {/* Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <User className="w-4 h-4 text-gray-500" />
                      <span className="text-sm text-gray-600">אל: {draft.originalEmail.from}</span>
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">
                      {draft.subject}
                    </h3>
                    <div className="flex items-center gap-2 text-sm text-gray-500">
                      <Clock className="w-4 h-4" />
                      <span>נוצר: {new Date(draft.createdAt).toLocaleString('he-IL')}</span>
                    </div>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => toggleExpanded(draft.id)}
                    className="text-gray-500 hover:text-gray-700"
                  >
                    {expandedDrafts[draft.id] ? <ChevronUp /> : <ChevronDown />}
                  </Button>
                </div>

                {/* Original Email (when expanded) */}
                {expandedDrafts[draft.id] && (
                  <motion.div
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: 'auto' }}
                    exit={{ opacity: 0, height: 0 }}
                    className="mb-4 p-4 bg-gray-50 rounded-lg"
                  >
                    <div className="flex items-center gap-2 mb-2">
                      <Mail className="w-4 h-4 text-gray-500" />
                      <span className="text-sm font-semibold text-gray-700">המייל המקורי:</span>
                    </div>
                    <div 
                      className="text-sm text-gray-600 prose prose-sm max-w-none"
                      dangerouslySetInnerHTML={{ __html: decodeBase64(draft.originalEmail.body) }}
                    />
                  </motion.div>
                )}

                {/* Draft Content */}
                <div className="mb-4">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <Edit3 className="w-4 h-4 text-blue-500" />
                      <span className="text-sm font-semibold text-gray-700">התשובה שלך:</span>
                    </div>
                    {!editingDrafts[draft.id] && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => toggleEdit(draft.id)}
                        className="text-blue-600 hover:text-blue-700"
                      >
                        ערוך
                      </Button>
                    )}
                  </div>
                  
                  {editingDrafts[draft.id] ? (
                    <div className="space-y-3">
                      <Textarea
                        defaultValue={draft.draftContent}
                        id={`draft-content-${draft.id}`}
                        className="min-h-[150px] w-full resize-y"
                        placeholder="ערוך את התשובה..."
                      />
                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          onClick={() => {
                            const textarea = document.getElementById(`draft-content-${draft.id}`);
                            updateDraft(draft.id, textarea.value);
                          }}
                          className="bg-green-600 hover:bg-green-700"
                        >
                          <CheckCircle className="w-4 h-4 ml-1" />
                          שמור שינויים
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => toggleEdit(draft.id)}
                        >
                          ביטול
                        </Button>
                      </div>
                    </div>
                  ) : (
                    <div 
                      className="p-4 bg-blue-50 rounded-lg prose prose-sm max-w-none"
                      dangerouslySetInnerHTML={{ __html: decodeBase64(draft.draftContent) }}
                    />
                  )}
                </div>

                {/* Actions */}
                <div className="flex items-center justify-between pt-4 border-t">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => deleteDraft(draft.id)}
                    className="text-red-600 hover:text-red-700 hover:bg-red-50"
                  >
                    <Trash2 className="w-4 h-4 ml-1" />
                    מחק טיוטה
                  </Button>
                  
                  <Button
                    onClick={() => sendDraft(draft.id)}
                    className="bg-blue-600 hover:bg-blue-700"
                  >
                    <Send className="w-4 h-4 ml-1" />
                    אשר ושלח תשובה
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
};

export default PendingReplies;