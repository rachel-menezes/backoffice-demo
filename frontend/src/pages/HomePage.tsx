import { useState, useEffect } from "react";
import type { FC } from 'react';
import SignIn from './SignIn';
import DenseAppBar from "../components/AppBar";
import DataTable from "../components/Table";
import Loading from '../components/Loading';
import { api } from "../api/api";
import { Config } from '../types';

interface HomePageProps {
    config: Config;
}

interface User {
    id: string;
    name: string;
}

const HomePage: FC<HomePageProps> = (props: any) => {
    const { config } = props;
    const [user, setUser] = useState<User | undefined>();
    const [data, setData] = useState();

    const fetchData = async () => {
        if (user) {
            const res = await api.getData(user.id);
            if (res && res.length > 0) {
                const processedData: any = [];
                res.forEach((r: any) => {
                    processedData.push({
                        'id': r[0],
                        'firstName': r[1],
                        'lastName': r[2],
                        'phoneNumber': r[3],
                        'email': r[4],
                        'fullName': r[5],
                        'location': r[9],
                    });
                });
                setData(processedData);
            }
        }
    };
    useEffect(() => {
        if (user) fetchData();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [user]);

    if (!user)
        return <SignIn config={config} setUser={setUser} />;

    if (!data)
        return <Loading />;

    return (
        <>
            <DenseAppBar user={user} setUser={setUser} config={config} />
            <DataTable rows={data} />
        </>);
};

export default HomePage;