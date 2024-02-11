import { NFTStorage } from "nft.storage";

import { NFT_STORAGE_TOKEN } from "@/ts/constants";

const client = new NFTStorage({ token: NFT_STORAGE_TOKEN });

export async function storeData(_dataToStore: string): Promise<string> {
  const dataToStore = new Blob([_dataToStore]);
  const cid = await client.storeBlob(dataToStore);

  return cid.toString();
}

export async function getData(_cid: string): Promise<string> {
  const gatewayUrl = `https://nftstorage.link/ipfs/${_cid}`;

  try {
    const response = await fetch(gatewayUrl);
    if (!response.ok) {
      throw new Error(`Error while retriving data from IPFS : ${response.statusText}`);
    }
    const jsonData = await response.json();
    return JSON.stringify(jsonData);
  } catch (error) {
    console.error("Error while retriving data from IPFS:", error);
    throw error;
  }
}
