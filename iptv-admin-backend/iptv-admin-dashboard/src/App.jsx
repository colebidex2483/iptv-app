import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import ActivationCodes from './pages/ActivationCodes';
import GenerateCode from './pages/GenerateCode';
import ActivateDevice from './pages/ActivateDevice';
import LicenseStatus from './pages/LicenseStatus';
import LicenseManagement from './pages/LicenseManagement';
import { Box } from '@mui/material';

export default function App() {
  return (
    <Router>
      <Box sx={{ display: 'flex' }}>
        <Sidebar />
        <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/activation-codes" element={<ActivationCodes />} />
            <Route path="/generate-code" element={<GenerateCode />} />
            <Route path="/activate-device" element={<ActivateDevice />} />
            <Route path="/license-status" element={<LicenseStatus />} />
            <Route path="/license-management" element={<LicenseManagement />} />
          </Routes>
        </Box>
      </Box>
    </Router>
  );
}
