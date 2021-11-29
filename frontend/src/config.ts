import { Config } from './types';
export const baseApiUri = process.env.NODE_ENV === 'development' ? "http://127.0.0.1:5000/api/v1" : "https://python-api-formal.herokuapp.com/api/v1";

export const config: Config = {
    name: process.env.REACT_APP_COMPANY_NAME || '',
    logoUrl: process.env.REACT_APP_COMPANY_LOGO || '',
    primaryColor: process.env.REACT_APP_PRIMARY_COLOR || '',
    secondaryColor: process.env.REACT_APP_SECONDARY_COLOR || '',
};