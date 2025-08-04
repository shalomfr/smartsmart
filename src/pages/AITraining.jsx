import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Button } from '../components/ui/button';
import { Textarea } from '../components/ui/textarea';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { Switch } from '../components/ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../components/ui/select';
import { Alert, AlertDescription } from '../components/ui/alert';
import { motion } from 'framer-motion';
import { 
  Brain, Save, RefreshCw, Zap, FileText, MessageSquare, 
  Settings, Plus, Trash2, Edit, Copy, Check
} from 'lucide-react';

export default function AITraining() {
  const [systemPrompt, setSystemPrompt] = useState('');
  const [templates, setTemplates] = useState([]);
  const [selectedTemplate, setSelectedTemplate] = useState('');
  const [tone, setTone] = useState('professional');
  const [language, setLanguage] = useState('auto');
  const [creativity, setCreativity] = useState(0.7);
  const [maxLength, setMaxLength] = useState(500);
  const [includeContext, setIncludeContext] = useState(true);
  const [autoCorrect, setAutoCorrect] = useState(true);
  const [showSuccess, setShowSuccess] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [newTemplateName, setNewTemplateName] = useState('');
  const [showNewTemplate, setShowNewTemplate] = useState(false);

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = () => {
    const saved = localStorage.getItem('aiTrainingSettings');
    if (saved) {
      const settings = JSON.parse(saved);
      setSystemPrompt(settings.systemPrompt || '');
      setTemplates(settings.templates || []);
      setTone(settings.tone || 'professional');
      setLanguage(settings.language || 'auto');
      setCreativity(settings.creativity || 0.7);
      setMaxLength(settings.maxLength || 500);
      setIncludeContext(settings.includeContext ?? true);
      setAutoCorrect(settings.autoCorrect ?? true);
    } else {
      // ברירת מחדל
      const defaultPrompt = `אתה עוזר דואר אלקטרוני מקצועי. 
עליך לכתוב תשובות בהתאם להנחיות הבאות:
- כתוב בסגנון מקצועי אך ידידותי
- שמור על תמציתיות וברירות
- התאם את השפה לשפת המייל המקורי
- הוסף ברכה מתאימה בהתאם לשעה ביום
- חתום עם "בברכה" או חתימה מתאימה אחרת`;
      
      setSystemPrompt(defaultPrompt);
      
      const defaultTemplates = [
        {
          id: '1',
          name: 'עסקי פורמלי',
          prompt: 'כתוב בסגנון עסקי פורמלי, השתמש בלשון רבים, הימנע מסלנג'
        },
        {
          id: '2',
          name: 'ידידותי',
          prompt: 'כתוב בסגנון חם וידידותי, אפשר להשתמש בהומור קל'
        },
        {
          id: '3',
          name: 'תמציתי',
          prompt: 'כתוב תשובות קצרות וישירות לעניין, ללא מילים מיותרות'
        }
      ];
      setTemplates(defaultTemplates);
    }
  };

  const saveSettings = () => {
    setIsLoading(true);
    const settings = {
      systemPrompt,
      templates,
      tone,
      language,
      creativity,
      maxLength,
      includeContext,
      autoCorrect
    };
    
    localStorage.setItem('aiTrainingSettings', JSON.stringify(settings));
    
    // שמור גם את ה-system prompt לשימוש ב-API
    localStorage.setItem('claudeSystemPrompt', systemPrompt);
    
    setTimeout(() => {
      setIsLoading(false);
      setShowSuccess(true);
      setTimeout(() => setShowSuccess(false), 3000);
    }, 500);
  };

  const addTemplate = () => {
    if (!newTemplateName.trim()) return;
    
    const newTemplate = {
      id: Date.now().toString(),
      name: newTemplateName,
      prompt: ''
    };
    
    setTemplates([...templates, newTemplate]);
    setSelectedTemplate(newTemplate.id);
    setNewTemplateName('');
    setShowNewTemplate(false);
  };

  const updateTemplate = (id, prompt) => {
    setTemplates(templates.map(t => 
      t.id === id ? { ...t, prompt } : t
    ));
  };

  const deleteTemplate = (id) => {
    setTemplates(templates.filter(t => t.id !== id));
    if (selectedTemplate === id) {
      setSelectedTemplate('');
    }
  };

  const applyTemplate = (template) => {
    setSystemPrompt(systemPrompt + '\n\n' + template.prompt);
  };

  const testPrompt = async () => {
    // כאן אפשר להוסיף פונקציונליות לבדיקת ה-prompt
    alert('בדיקת ה-prompt תתבצע בפעם הבאה שתשתמש בפיצרי AI');
  };

  return (
    <div className="p-4 md:p-8 flex-1 bg-gradient-to-br from-gray-50 via-purple-50/30 to-indigo-50/50" dir="rtl">
      {/* Header */}
      <motion.div
        className="max-w-4xl mx-auto mb-8 text-center"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <motion.div
          className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-purple-500 to-indigo-600 rounded-2xl shadow-lg mb-4"
          whileHover={{ scale: 1.1, rotate: [0, -5, 5, 0] }}
        >
          <Brain className="w-8 h-8 text-white" />
        </motion.div>
        <h1 className="text-3xl font-bold bg-gradient-to-r from-gray-900 to-gray-600 bg-clip-text text-transparent">
          אימון ה-AI
        </h1>
        <p className="text-gray-500 mt-2">הגדר איך אתה רוצה שה-AI יכתוב עבורך</p>
      </motion.div>

      <div className="max-w-4xl mx-auto grid lg:grid-cols-3 gap-6">
        {/* Main Settings */}
        <motion.div
          className="lg:col-span-2"
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
        >
          <Card className="border-0 shadow-lg bg-white/80 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MessageSquare className="w-5 h-5 text-purple-500" />
                הגדרת התנהגות ה-AI
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* System Prompt */}
              <div className="space-y-2">
                <Label className="text-sm font-semibold">הנחיות כלליות ל-AI</Label>
                <Textarea
                  value={systemPrompt}
                  onChange={(e) => setSystemPrompt(e.target.value)}
                  placeholder="הסבר ל-AI איך אתה רוצה שיכתוב מיילים..."
                  className="min-h-[200px] resize-none"
                />
                <p className="text-xs text-gray-500">
                  כתוב בשפה חופשית איך אתה רוצה שה-AI יתנהג. למשל: "תמיד תתחיל עם ברכה חמה" או "השתמש בהומור קל"
                </p>
              </div>

              {/* Tone Selection */}
              <div className="space-y-2">
                <Label>סגנון כתיבה ברירת מחדל</Label>
                <Select value={tone} onValueChange={setTone}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="professional">מקצועי</SelectItem>
                    <SelectItem value="friendly">ידידותי</SelectItem>
                    <SelectItem value="formal">פורמלי</SelectItem>
                    <SelectItem value="casual">יומיומי</SelectItem>
                    <SelectItem value="creative">יצירתי</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Language */}
              <div className="space-y-2">
                <Label>שפת ברירת מחדל</Label>
                <Select value={language} onValueChange={setLanguage}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="auto">זיהוי אוטומטי</SelectItem>
                    <SelectItem value="hebrew">עברית</SelectItem>
                    <SelectItem value="english">English</SelectItem>
                    <SelectItem value="arabic">العربية</SelectItem>
                    <SelectItem value="russian">Русский</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Creativity Slider */}
              <div className="space-y-2">
                <Label>רמת יצירתיות: {creativity}</Label>
                <input
                  type="range"
                  min="0"
                  max="1"
                  step="0.1"
                  value={creativity}
                  onChange={(e) => setCreativity(parseFloat(e.target.value))}
                  className="w-full"
                />
                <div className="flex justify-between text-xs text-gray-500">
                  <span>שמרני</span>
                  <span>מאוזן</span>
                  <span>יצירתי</span>
                </div>
              </div>

              {/* Max Length */}
              <div className="space-y-2">
                <Label>אורך מקסימלי (מילים)</Label>
                <Input
                  type="number"
                  value={maxLength}
                  onChange={(e) => setMaxLength(parseInt(e.target.value))}
                  min="50"
                  max="2000"
                />
              </div>

              {/* Switches */}
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <Label>כלול הקשר מהמייל המקורי</Label>
                    <p className="text-xs text-gray-500">ה-AI יתייחס לתוכן המייל המקורי</p>
                  </div>
                  <Switch
                    checked={includeContext}
                    onCheckedChange={setIncludeContext}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <Label>תיקון אוטומטי</Label>
                    <p className="text-xs text-gray-500">תקן שגיאות כתיב ודקדוק</p>
                  </div>
                  <Switch
                    checked={autoCorrect}
                    onCheckedChange={setAutoCorrect}
                  />
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 pt-4">
                <Button
                  onClick={saveSettings}
                  disabled={isLoading}
                  className="flex-1 bg-gradient-to-r from-purple-500 to-indigo-600"
                >
                  {isLoading ? (
                    <motion.div animate={{ rotate: 360 }} transition={{ duration: 1, repeat: Infinity }}>
                      <RefreshCw className="w-4 h-4 ml-2" />
                    </motion.div>
                  ) : (
                    <Save className="w-4 h-4 ml-2" />
                  )}
                  שמור הגדרות
                </Button>
                <Button
                  variant="outline"
                  onClick={testPrompt}
                >
                  <Zap className="w-4 h-4 ml-2" />
                  בדוק
                </Button>
              </div>

              {showSuccess && (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                >
                  <Alert className="bg-green-50 border-green-200">
                    <Check className="w-4 h-4 text-green-600" />
                    <AlertDescription className="text-green-800">
                      ההגדרות נשמרו בהצלחה!
                    </AlertDescription>
                  </Alert>
                </motion.div>
              )}
            </CardContent>
          </Card>
        </motion.div>

        {/* Templates */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
        >
          <Card className="border-0 shadow-lg bg-white/80 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="flex items-center justify-between">
                <span className="flex items-center gap-2">
                  <FileText className="w-5 h-5 text-indigo-500" />
                  תבניות מוכנות
                </span>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => setShowNewTemplate(!showNewTemplate)}
                >
                  <Plus className="w-4 h-4" />
                </Button>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {showNewTemplate && (
                <motion.div
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  className="flex gap-2 mb-3"
                >
                  <Input
                    value={newTemplateName}
                    onChange={(e) => setNewTemplateName(e.target.value)}
                    placeholder="שם התבנית"
                    onKeyPress={(e) => e.key === 'Enter' && addTemplate()}
                  />
                  <Button size="sm" onClick={addTemplate}>
                    <Check className="w-4 h-4" />
                  </Button>
                </motion.div>
              )}

              {templates.map((template, index) => (
                <motion.div
                  key={template.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  className={`p-3 rounded-lg border cursor-pointer transition-all ${
                    selectedTemplate === template.id
                      ? 'bg-purple-50 border-purple-300'
                      : 'bg-gray-50 hover:bg-gray-100'
                  }`}
                  onClick={() => setSelectedTemplate(template.id)}
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-medium text-sm">{template.name}</span>
                    <div className="flex gap-1">
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={(e) => {
                          e.stopPropagation();
                          applyTemplate(template);
                        }}
                      >
                        <Copy className="w-3 h-3" />
                      </Button>
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={(e) => {
                          e.stopPropagation();
                          deleteTemplate(template.id);
                        }}
                      >
                        <Trash2 className="w-3 h-3" />
                      </Button>
                    </div>
                  </div>
                  
                  {selectedTemplate === template.id && (
                    <Textarea
                      value={template.prompt}
                      onChange={(e) => updateTemplate(template.id, e.target.value)}
                      placeholder="הגדר את התבנית..."
                      className="text-xs min-h-[80px] mt-2"
                      onClick={(e) => e.stopPropagation()}
                    />
                  )}
                </motion.div>
              ))}

              <div className="pt-4 border-t">
                <h4 className="text-sm font-medium mb-2">דוגמאות להנחיות:</h4>
                <ul className="text-xs text-gray-600 space-y-1">
                  <li>• "תמיד סיים עם שאלה לעידוד המשך השיחה"</li>
                  <li>• "השתמש באימוג'ים בצורה מתונה"</li>
                  <li>• "הימנע משימוש במילים לועזיות"</li>
                  <li>• "התחל כל מייל עם התייחסות אישית"</li>
                </ul>
              </div>
            </CardContent>
          </Card>

          {/* Info Card */}
          <Card className="border-0 shadow-lg bg-white/80 backdrop-blur-sm mt-6">
            <CardContent className="pt-6">
              <div className="space-y-3">
                <div className="flex items-start gap-3">
                  <Brain className="w-5 h-5 text-purple-500 mt-0.5" />
                  <div>
                    <h4 className="font-medium text-sm">איך זה עובד?</h4>
                    <p className="text-xs text-gray-600 mt-1">
                      ההנחיות שלך משפיעות על כל הפיצרים של ה-AI - תשובות חכמות, 
                      שיפור טקסטים ויצירת כותרות.
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-3">
                  <Settings className="w-5 h-5 text-indigo-500 mt-0.5" />
                  <div>
                    <h4 className="font-medium text-sm">טיפ מקצועי</h4>
                    <p className="text-xs text-gray-600 mt-1">
                      כתוב הנחיות ספציפיות ומפורטות. ככל שתהיה מדויק יותר, 
                      כך ה-AI יבין טוב יותר את הסגנון שלך.
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}
