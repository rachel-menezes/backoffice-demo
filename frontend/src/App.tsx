import React from 'react';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';

import HomePage from './pages/HomePage';
import { config } from './config';
const App = () => {

  const theme = createTheme({
    palette: {
      primary: {
        main: config.primaryColor,
        contrastText: config.secondaryColor
      },
      secondary: {
        main: config.secondaryColor,
      }
    }
  });
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <HomePage config={config} />
    </ThemeProvider>

  );
};

export default App;
