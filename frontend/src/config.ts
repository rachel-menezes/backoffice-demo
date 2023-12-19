import { Config } from './types';
export const baseApiUri = process.env.REACT_APP_API_URL || '';

export const config: Config = {
    name: process.env.REACT_APP_COMPANY_NAME || '',
    logoUrl: process.env.REACT_APP_COMPANY_LOGO || '',
    primaryColor: process.env.REACT_APP_PRIMARY_COLOR || '',
    secondaryColor: process.env.REACT_APP_SECONDARY_COLOR || '',
    thirdColor: process.env.REACT_APP_THIRD_COLOR || '',
};
