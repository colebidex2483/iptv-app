import React, { useEffect, useState } from 'react';
import { Typography, Grid, Paper, Container } from '@mui/material';
import axios from '../services/api';

export default function Dashboard() {
  const [stats, setStats] = useState({ total: 0, used: 0, unused: 0 });
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const resAll = await axios.get('/codes');
        const codes = resAll.data.codes;
        const usedCount = codes.filter((c) => c.isUsed).length;
        const unusedCount = codes.length - usedCount;
        setStats({ total: codes.length, used: usedCount, unused: unusedCount });
        setError(''); // clear error on success
      } catch (err) {
        console.error(err);
        setError('Failed to load stats.');
      }
    };
    fetchStats();
  }, []);

  if (error) {
    return (
      <Container sx={{ mt: 4, mb: 4 }}>
        <Typography variant="h6" color="error" align="center">
          {error}
        </Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Typography
        variant="h4"
        gutterBottom
        sx={{
          fontWeight: '700',
          color: 'primary.main',
          mb: 4,
          textAlign: { xs: 'center', md: 'left' },
        }}
      >
        Dashboard
      </Typography>

      <Grid container spacing={4}>
        {[
          { label: 'Total Codes', value: stats.total, color: 'primary.main' },
          { label: 'Used Codes', value: stats.used, color: 'error.main' },
          { label: 'Unused Codes', value: stats.unused, color: 'success.main' },
        ].map(({ label, value, color }) => (
          <Grid item xs={12} sm={6} md={4} key={label}>
            <Paper
              elevation={6}
              sx={{
                p: 4,
                borderRadius: 3,
                boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                bgcolor: 'background.paper',
                transition: 'transform 0.3s ease',
                '&:hover': {
                  transform: 'translateY(-5px)',
                  boxShadow: '0 8px 20px rgba(0, 0, 0, 0.15)',
                },
              }}
            >
              <Typography
                variant="subtitle1"
                sx={{
                  mb: 1,
                  fontWeight: 600,
                  color: 'text.secondary',
                  textTransform: 'uppercase',
                  letterSpacing: 1.2,
                }}
              >
                {label}
              </Typography>
              <Typography
                variant="h3"
                sx={{ color, fontWeight: 'bold', userSelect: 'none' }}
              >
                {value}
              </Typography>
            </Paper>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
}
