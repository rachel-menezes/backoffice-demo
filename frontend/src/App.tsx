import React, { useState, useEffect } from 'react';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';

import HomePage from './pages/HomePage';
import Loading from './components/Loading';
import { api } from "./api/api";
import { Config } from './types';

const App = () => {
  const [config, setConfig] = useState<Config | undefined>();
  useEffect(() => {
    const fetchConfig = async () => {
      const cfg: Config = await api.getConfig(process.env.REACT_APP_COMPANY_NAME ?? '');
      setConfig(cfg);
    };
    fetchConfig();
  }, []);

  if (!config)
    return <Loading />;

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
