import React, { useState } from 'react';
import {
  Container,
  Typography,
  TextField,
  Button,
  Box,
  Alert,
  CircularProgress,
} from '@mui/material';
import axios from '../services/api';

export default function ActivateDevice() {
  const [code, setCode] = useState('');
  const [deviceId, setDeviceId] = useState('');
  const [deviceInfo, setDeviceInfo] = useState('');
  const [loading, setLoading] = useState(false);
  const [responseMsg, setResponseMsg] = useState(null);
  const [errorMsg, setErrorMsg] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setResponseMsg(null);
    setErrorMsg(null);

    if (!code.trim() || !deviceId.trim()) {
      setErrorMsg('Activation code and Device ID are required.');
      return;
    }

    setLoading(true);

    try {
      const payload = {
        code: code.trim(),
        deviceId: deviceId.trim(),
        deviceInfo: deviceInfo.trim() || null,
      };
      const res = await axios.post('/activation-codes/activate', payload);
      setResponseMsg(res.data.message + (res.data.expiresAt ? ` Expires At: ${new Date(res.data.expiresAt).toLocaleDateString()}` : ''));
      setCode('');
      setDeviceId('');
      setDeviceInfo('');
    } catch (error) {
      setErrorMsg(error.response?.data?.message || 'Activation failed.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ mt: 6 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: '700', color: 'primary.main' }}>
        Activate Device
      </Typography>

      <Box component="form" onSubmit={handleSubmit} noValidate sx={{ mt: 3 }}>
        <TextField
          label="Activation Code"
          fullWidth
          required
          value={code}
          onChange={(e) => setCode(e.target.value.toUpperCase())}
          margin="normal"
        />

        <TextField
          label="Device ID"
          fullWidth
          required
          value={deviceId}
          onChange={(e) => setDeviceId(e.target.value)}
          margin="normal"
        />

        <TextField
          label="Device Info (optional)"
          fullWidth
          value={deviceInfo}
          onChange={(e) => setDeviceInfo(e.target.value)}
          margin="normal"
          placeholder="e.g. IP, MAC address, device model"
        />

        {responseMsg && <Alert severity="success" sx={{ my: 2 }}>{responseMsg}</Alert>}
        {errorMsg && <Alert severity="error" sx={{ my: 2 }}>{errorMsg}</Alert>}

        <Button
          type="submit"
          variant="contained"
          color="primary"
          disabled={loading}
          fullWidth
          sx={{ mt: 2 }}
        >
          {loading ? <CircularProgress size={24} /> : 'Activate'}
        </Button>
      </Box>
    </Container>
  );
}
