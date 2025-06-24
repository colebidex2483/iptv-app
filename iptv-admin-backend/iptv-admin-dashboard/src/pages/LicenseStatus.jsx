import React, { useState } from 'react';
import {
  Container,
  Typography,
  TextField,
  Button,
  Box,
  Alert,
  CircularProgress,
  Paper,
  Grid,
} from '@mui/material';
import axios from '../services/api';

export default function LicenseStatus() {
  const [deviceId, setDeviceId] = useState('');
  const [loading, setLoading] = useState(false);
  const [license, setLicense] = useState(null);
  const [errorMsg, setErrorMsg] = useState(null);

  const fetchLicense = async () => {
    setLoading(true);
    setLicense(null);
    setErrorMsg(null);

    if (!deviceId.trim()) {
      setErrorMsg('Device ID is required.');
      setLoading(false);
      return;
    }

    try {
      const res = await axios.get(`/license/status/${deviceId.trim()}`);
      setLicense(res.data);
    } catch (error) {
      setErrorMsg(error.response?.data?.message || 'Failed to fetch license status.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ mt: 6 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: '700', color: 'primary.main' }}>
        License Status
      </Typography>

      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField
          label="Device ID"
          fullWidth
          value={deviceId}
          onChange={(e) => setDeviceId(e.target.value)}
        />
        <Button variant="contained" onClick={fetchLicense} disabled={loading}>
          {loading ? <CircularProgress size={24} /> : 'Check'}
        </Button>
      </Box>

      {errorMsg && <Alert severity="error" sx={{ mb: 2 }}>{errorMsg}</Alert>}

      {license && (
        <Paper sx={{ p: 3 }}>
          <Grid container spacing={2}>
            <Grid item xs={12}>
              <Typography variant="h6" gutterBottom>
                Device License Info
              </Typography>
            </Grid>
            <Grid item xs={6}>
              <Typography variant="subtitle2" color="text.secondary">Activation Code:</Typography>
              <Typography>{license.activationCode || '-'}</Typography>
            </Grid>
            <Grid item xs={6}>
              <Typography variant="subtitle2" color="text.secondary">Activated:</Typography>
              <Typography>{license.activated ? 'Yes' : 'No'}</Typography>
            </Grid>
            <Grid item xs={6}>
              <Typography variant="subtitle2" color="text.secondary">Expires At:</Typography>
              <Typography>{license.expiresAt ? new Date(license.expiresAt).toLocaleDateString() : '-'}</Typography>
            </Grid>
            <Grid item xs={6}>
              <Typography variant="subtitle2" color="text.secondary">Device Info:</Typography>
              <Typography>{license.deviceId || '-'}</Typography>
            </Grid>
          </Grid>
        </Paper>
      )}
    </Container>
  );
}
