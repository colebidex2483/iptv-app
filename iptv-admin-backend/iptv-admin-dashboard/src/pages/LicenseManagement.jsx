import React, { useEffect, useState } from 'react';
import {
  Container, Typography, Table, TableBody, TableCell,
  TableHead, TableRow, Paper, Button, CircularProgress, Stack, Snackbar, Alert
} from '@mui/material';
import axios from '../services/api';

export default function LicenseManagement() {
  const [licenses, setLicenses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  const fetchLicenses = async () => {
    setLoading(true);
    try {
      const res = await axios.get('/users'); // Assumes /users returns user/device list
      setLicenses(res.data || []);
      setError('');
    } catch (err) {
      console.error(err);
      setError('Failed to load licenses.');
    } finally {
      setLoading(false);
    }
  };

  const handleRenew = async (deviceId) => {
    try {
      await axios.post('/license/renew', { deviceId, extensionMonths: 1 });
      setSuccessMsg('License renewed');
      fetchLicenses();
    } catch (err) {
      console.error('Renew failed:', err);
      setError('Renewal failed.');
    }
  };

  const handleRevoke = async (deviceId) => {
    try {
      await axios.post('/license/revoke', { deviceId });
      setSuccessMsg('License revoked');
      fetchLicenses();
    } catch (err) {
      console.error('Revoke failed:', err);
      setError('Revoke failed.');
    }
  };

  useEffect(() => {
    fetchLicenses();
  }, []);

  return (
    <Container sx={{ mt: 4 }}>
      <Typography variant="h4" gutterBottom>License Management</Typography>

      {loading ? (
        <CircularProgress />
      ) : error ? (
        <Typography color="error">{error}</Typography>
      ) : (
        <Paper sx={{ mt: 2 }}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Device ID</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Expires At</TableCell>
                <TableCell>Activated</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {licenses.map((lic) => (
                <TableRow key={lic.deviceId || lic.id}>
                  <TableCell>{lic.deviceId || 'N/A'}</TableCell>
                  <TableCell>{lic.status || 'N/A'}</TableCell>
                  <TableCell>{lic.expiresAt ? new Date(lic.expiresAt).toLocaleDateString() : '—'}</TableCell>
                  <TableCell>{lic.activated ? 'Yes' : 'No'}</TableCell>
                  <TableCell>
                    <Stack direction="row" spacing={1}>
                      <Button
                        variant="outlined"
                        color="primary"
                        onClick={() => handleRenew(lic.deviceId)}
                        disabled={lic.status === 'revoked'}
                      >
                        Renew
                      </Button>
                      <Button
                        variant="outlined"
                        color="error"
                        onClick={() => handleRevoke(lic.deviceId)}
                        disabled={lic.status === 'revoked'}
                      >
                        Revoke
                      </Button>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}

      <Snackbar
        open={!!successMsg}
        autoHideDuration={4000}
        onClose={() => setSuccessMsg('')}
      >
        <Alert onClose={() => setSuccessMsg('')} severity="success">
          {successMsg}
        </Alert>
      </Snackbar>

      <Snackbar
        open={!!error && !loading}
        autoHideDuration={4000}
        onClose={() => setError('')}
      >
        <Alert onClose={() => setError('')} severity="error">
          {error}
        </Alert>
      </Snackbar>
    </Container>
  );
}