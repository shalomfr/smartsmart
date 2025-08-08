import Layout from "./Layout.jsx";

import Inbox from "./Inbox";

import Settings from "./Settings";

import Compose from "./Compose";

import Contacts from "./Contacts";

import Tasks from "./Tasks";

import Rules from "./Rules";

import SmartFeatures from "./SmartFeatures";

import Search from "./Search";

import AITraining from "./AITraining";

import PendingReplies from "./PendingReplies";

import Login from "./Login";

import ProtectedRoute from "../components/ProtectedRoute";

import { HashRouter as Router, Route, Routes, useLocation } from 'react-router-dom';

const PAGES = {
    
    Inbox: Inbox,
    
    Settings: Settings,
    
    Compose: Compose,
    
    Contacts: Contacts,
    
    Tasks: Tasks,
    
    Rules: Rules,
    
    SmartFeatures: SmartFeatures,
    
    Search: Search,
    
    AITraining: AITraining,
    
    PendingReplies: PendingReplies,
    
}

function _getCurrentPage(url) {
    if (url.endsWith('/')) {
        url = url.slice(0, -1);
    }
    let urlLastPart = url.split('/').pop();
    if (urlLastPart.includes('?')) {
        urlLastPart = urlLastPart.split('?')[0];
    }

    const pageName = Object.keys(PAGES).find(page => page.toLowerCase() === urlLastPart.toLowerCase());
    return pageName || Object.keys(PAGES)[0];
}

// Create a wrapper component that uses useLocation inside the Router context
function PagesContent() {
    const location = useLocation();
    const currentPage = _getCurrentPage(location.pathname);
    
    // אם אנחנו בעמוד הכניסה, לא נציג את ה-Layout
    if (location.pathname === '/login') {
        return (
            <Routes>
                <Route path="/login" element={<Login />} />
            </Routes>
        );
    }
    
    return (
        <Layout currentPageName={currentPage}>
            <Routes>            
                <Route path="/" element={
                    <ProtectedRoute>
                        <Inbox />
                    </ProtectedRoute>
                } />
                
                <Route path="/login" element={<Login />} />
                
                <Route path="/Inbox" element={
                    <ProtectedRoute>
                        <Inbox />
                    </ProtectedRoute>
                } />
                
                <Route path="/Settings" element={
                    <ProtectedRoute>
                        <Settings />
                    </ProtectedRoute>
                } />
                
                <Route path="/Compose" element={
                    <ProtectedRoute>
                        <Compose />
                    </ProtectedRoute>
                } />
                
                <Route path="/Contacts" element={
                    <ProtectedRoute>
                        <Contacts />
                    </ProtectedRoute>
                } />
                
                <Route path="/Tasks" element={
                    <ProtectedRoute>
                        <Tasks />
                    </ProtectedRoute>
                } />
                
                <Route path="/Rules" element={
                    <ProtectedRoute>
                        <Rules />
                    </ProtectedRoute>
                } />
                
                <Route path="/SmartFeatures" element={
                    <ProtectedRoute>
                        <SmartFeatures />
                    </ProtectedRoute>
                } />
                
                <Route path="/Search" element={
                    <ProtectedRoute>
                        <Search />
                    </ProtectedRoute>
                } />
                
                <Route path="/AITraining" element={
                    <ProtectedRoute>
                        <AITraining />
                    </ProtectedRoute>
                } />
                
                <Route path="/PendingReplies" element={
                    <ProtectedRoute>
                        <PendingReplies />
                    </ProtectedRoute>
                } />
                
            </Routes>
        </Layout>
    );
}

export default function Pages() {
    return (
        <Router>
            <PagesContent />
        </Router>
    );
}

