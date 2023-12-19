import { Config } from './types';
export const baseApiUri = process.env.REACT_APP_API_URL || 'https://backoffice-ecgz.onrender.com/api/v1';

export const config: Config = {
    name: process.env.REACT_APP_COMPANY_NAME || 'Rippling',
    logoUrl: process.env.REACT_APP_COMPANY_LOGO || 'https://imagedelivery.net/YV7tiPr1pNu8eWcEhMhZuA/fd5fa43c-9fd0-4067-8b05-a6adc4d12300/public',
    primaryColor: process.env.REACT_APP_PRIMARY_COLOR || '#fdb71c',
    secondaryColor: process.env.REACT_APP_SECONDARY_COLOR || '#fff',
    thirdColor: process.env.REACT_APP_THIRD_COLOR || '',
};
