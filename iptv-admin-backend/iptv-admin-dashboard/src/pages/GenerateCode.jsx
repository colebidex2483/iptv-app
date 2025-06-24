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

export default function GenerateCode() {
  const [count, setCount] = useState(1);
  const [expiresAt, setExpiresAt] = useState('');
  const [loading, setLoading] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSuccessMsg('');
    setErrorMsg('');

    if (count < 1) {
      setErrorMsg('Please enter a valid number of codes to generate (minimum 1).');
      return;
    }

    setLoading(true);

    try {
      const payload = { count };
      if (expiresAt) {
        payload.expiresAt = expiresAt; // expects ISO string or yyyy-mm-dd format
      }
      const res = await axios.post('/generate-code', payload);
      setSuccessMsg(`${res.data.generatedCount} activation code(s) generated successfully.`);
      setCount(1);
      setExpiresAt('');
    } catch (error) {
      setErrorMsg(error.response?.data?.message || 'Failed to generate codes.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ mt: 6 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: '700', color: 'primary.main' }}>
        Generate Activation Codes
      </Typography>

      <Box component="form" onSubmit={handleSubmit} noValidate sx={{ mt: 3 }}>
        <TextField
          label="Number of Codes"
          type="number"
          inputProps={{ min: 1 }}
          fullWidth
          required
          value={count}
          onChange={(e) => setCount(Number(e.target.value))}
          margin="normal"
        />

        <TextField
          label="Expiration Date (optional)"
          type="date"
          fullWidth
          value={expiresAt}
          onChange={(e) => setExpiresAt(e.target.value)}
          margin="normal"
          InputLabelProps={{ shrink: true }}
        />

        {successMsg && <Alert severity="success" sx={{ my: 2 }}>{successMsg}</Alert>}
        {errorMsg && <Alert severity="error" sx={{ my: 2 }}>{errorMsg}</Alert>}

        <Button
          type="submit"
          variant="contained"
          color="primary"
          disabled={loading}
          fullWidth
          sx={{ mt: 2 }}
        >
          {loading ? <CircularProgress size={24} /> : 'Generate Codes'}
        </Button>
      </Box>
    </Container>
  );
}
