import { DataGrid, GridColDef } from '@mui/x-data-grid';
import { Box } from '@mui/material';

const columns: GridColDef[] = [
    { field: 'id', headerName: 'ID', width: 120 },
    { field: 'firstName', headerName: 'First name', width: 150 },
    { field: 'lastName', headerName: 'Last name', width: 150 },
    {
        field: 'phoneNumber',
        headerName: 'Phone number',
        width: 200,
    },
    {
        field: 'email',
        headerName: 'Email',
        width: 400,
    },
    {
        field: 'fullName',
        headerName: 'Full name',
        width: 300,
    },
    {
        field: 'location',
        headerName: 'Location',
        width: 500,
    },
];

export default function DataTable(props: any) {
    const { rows } = props;

    return (
        <Box p={2} style={{ height: '100vh', width: '100%' }}>
            <DataGrid
                rows={rows}
                columns={columns}
                pageSize={50}
                rowsPerPageOptions={[10]}
                checkboxSelection
            />
        </Box>
    );
}
