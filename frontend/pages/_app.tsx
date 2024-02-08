import ReactNode from "react";

import Layout from "@/components/struct/Layout";

interface PropsType {
  Component: any;
  pageProps: any;
}

export default function MyApp({ Component, pageProps }: PropsType) {
  return (
    <Layout>
      <Component {...pageProps} />
    </Layout>
  );
}
