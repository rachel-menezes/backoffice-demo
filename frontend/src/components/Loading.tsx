import { Box } from '@mui/material';
import CircularProgress from '@mui/material/CircularProgress';

const CircularIndeterminate = () => (
    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}>
        <CircularProgress />
    </Box>
);

export default CircularIndeterminate;