import '../styles/globals.css'
import type { AppProps } from 'next/app'
import { WagmiConfig, createClient, chain } from "wagmi";
import { ConnectKitProvider, getDefaultClient } from "connectkit";

const alchemyId = process.env.ALCHEMY_ID;
const chains = [chain.goerli];
const client = createClient(
  getDefaultClient({
    appName: "Paper Score",
    alchemyId,
    chains
  }),
);

export default function App({ Component, pageProps }: AppProps) {
  return (
  <WagmiConfig client={client}>
  <ConnectKitProvider>
  <Component {...pageProps} />
  </ConnectKitProvider>
    </WagmiConfig>
    )
}
