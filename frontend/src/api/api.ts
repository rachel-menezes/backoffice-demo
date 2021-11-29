import axios from 'axios';

import { baseApiUri } from '../config';

class Api {
    async login(email: string, password: string): Promise<any> {
        const res = await axios.post(`${baseApiUri}/sign-in`, {
            email,
            password
        });

        return Promise.resolve(res.data);
    }

    async getData(id: string): Promise<any> {
        const res = await axios.get(`${baseApiUri}/fetch-all?endUserID=${id}`);

        return Promise.resolve(res.data);
    }

    async getConfig(companyName: string): Promise<any> {
        const res = await axios.get(`${baseApiUri}/company-cfg?companyName=${companyName}`);

        return Promise.resolve(res.data);
    }
}

export const api = new Api();