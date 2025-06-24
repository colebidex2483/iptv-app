// components/Sidebar.jsx
import React from 'react';
import {
  Drawer,
  List,
  ListItemButton,
  ListItemText,
  Toolbar,
  Typography,
  useTheme,
} from '@mui/material';
import { Link, useLocation } from 'react-router-dom';
import DashboardIcon from '@mui/icons-material/Dashboard';
import VpnKeyIcon from '@mui/icons-material/VpnKey';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import DevicesIcon from '@mui/icons-material/Devices';
import InfoIcon from '@mui/icons-material/Info';
import ManageAccountsIcon from '@mui/icons-material/ManageAccounts';

const drawerWidth = 240;

const links = [
  { path: '/', label: 'Dashboard', icon: <DashboardIcon /> },
  { path: '/activation-codes', label: 'Activation Codes', icon: <VpnKeyIcon /> },
  { path: '/generate-code', label: 'Generate Code', icon: <AddCircleOutlineIcon /> },
  { path: '/activate-device', label: 'Activate Device', icon: <DevicesIcon /> },
  { path: '/license-status', label: 'License Status', icon: <InfoIcon /> },
  { path: '/license-management', label: 'License Management', icon: <ManageAccountsIcon /> },
];

export default function Sidebar() {
  const location = useLocation();
  const theme = useTheme();

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: {
          width: drawerWidth,
          boxSizing: 'border-box',
          backgroundColor: theme.palette.background.paper,
        },
      }}
      aria-label="Sidebar navigation"
    >
      <Toolbar
        sx={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          height: 64,
          px: 2,
          borderBottom: `1px solid ${theme.palette.divider}`,
        }}
      >
        <Typography variant="h6" noWrap>
          IPTV Admin
        </Typography>
      </Toolbar>

      <List component="nav" aria-labelledby="sidebar-navigation">
        {links.map(({ path, label, icon }) => {
          const selected = location.pathname === path;

          return (
            <ListItemButton
              key={path}
              component={Link}
              to={path}
              selected={selected}
              aria-current={selected ? 'page' : undefined}
              sx={{
                px: 3,
                '&.Mui-selected': {
                  bgcolor: theme.palette.action.selected,
                  color: theme.palette.primary.main,
                  fontWeight: 'bold',
                  '& svg': {
                    color: theme.palette.primary.main,
                  },
                },
                '&:hover': {
                  bgcolor: theme.palette.action.hover,
                },
                display: 'flex',
                alignItems: 'center',
                gap: 1.5,
              }}
            >
              {icon}
              <ListItemText primary={label} />
            </ListItemButton>
          );
        })}
      </List>
    </Drawer>
  );
}
