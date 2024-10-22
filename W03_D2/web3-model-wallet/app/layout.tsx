import type {Metadata} from "next";
import "./globals.css";
import Header from "@/components/header";
import {headers} from 'next/headers' // added
import ContextProvider from '@/context/index'

export const metadata: Metadata = {
    title: "Create Next App",
    description: "Generated by create next app",
};

export default function RootLayout({
                                       children,
                                   }: Readonly<{
    children: React.ReactNode;
}>) {
    const cookies = headers().get('cookie')
    return (
        <html lang="en">
        <body>
        <ContextProvider cookies={cookies}>
            <Header/>
            <main>
                {children}
            </main>
        </ContextProvider>
        </body>
        </html>
    );
}
