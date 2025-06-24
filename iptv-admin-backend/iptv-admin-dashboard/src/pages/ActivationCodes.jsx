import React, { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Table,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
  TablePagination,
  TextField,
  Paper,
  Chip,
  Box,
  CircularProgress,
  Alert,
} from '@mui/material';
import axios from '../services/api';

export default function ActivationCodes() {
  const [codes, setCodes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Pagination
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  // Search
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    const fetchCodes = async () => {
      try {
        setLoading(true);
        const res = await axios.get('/codes');
        setCodes(res.data.codes || []);
        setError(null);
      } catch (err) {
        console.error(err);
        setError('Failed to load activation codes.');
      } finally {
        setLoading(false);
      }
    };
    fetchCodes();
  }, []);

  // Handle pagination change
  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  // Handle rows per page change
  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  // Filter codes by search term (search in code string)
  const filteredCodes = codes.filter((code) =>
    code.code.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Slice for pagination
  const paginatedCodes = filteredCodes.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  );

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Typography
        variant="h4"
        gutterBottom
        sx={{ fontWeight: '700', color: 'primary.main', mb: 4 }}
      >
        Activation Codes
      </Typography>

      <Paper sx={{ mb: 2, p: 2 }}>
        <TextField
          label="Search codes"
          variant="outlined"
          fullWidth
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </Paper>

      {loading ? (
        <Box textAlign="center" mt={4}>
          <CircularProgress />
        </Box>
      ) : error ? (
        <Alert severity="error">{error}</Alert>
      ) : (
        <>
          <Paper>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Code</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Assigned To</TableCell>
                  <TableCell>Created At</TableCell>
                  <TableCell>Used At</TableCell>
                  <TableCell>Expires At</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {paginatedCodes.map((code) => (
                  <TableRow key={code.code}>
                    <TableCell sx={{ fontFamily: 'monospace' }}>{code.code}</TableCell>
                    <TableCell>
                      <Chip
                        label={code.isUsed ? 'Used' : 'Unused'}
                        color={code.isUsed ? 'error' : 'success'}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>{code.assignedTo || '-'}</TableCell>
                    <TableCell>
                      {code.createdAt ? new Date(code.createdAt).toLocaleString() : '-'}
                    </TableCell>
                    <TableCell>
                      {code.usedAt ? new Date(code.usedAt).toLocaleString() : '-'}
                    </TableCell>
                    <TableCell>
                      {code.expiresAt ? new Date(code.expiresAt).toLocaleDateString() : '-'}
                    </TableCell>
                  </TableRow>
                ))}

                {paginatedCodes.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={6} align="center">
                      No codes found.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>

            <TablePagination
              component="div"
              count={filteredCodes.length}
              page={page}
              onPageChange={handleChangePage}
              rowsPerPage={rowsPerPage}
              onRowsPerPageChange={handleChangeRowsPerPage}
              rowsPerPageOptions={[5, 10, 25]}
            />
          </Paper>
        </>
      )}
    </Container>
  );
}
