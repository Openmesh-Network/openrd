import { Deployer } from "../../web3webdeploy/types";
import { Buffer } from "buffer";

export async function deployCounter(deployer: Deployer) {
  return await deployer.deploy({
    id: "Counter",
    contract: "Counter",
    salt: new Uint8Array(
      Buffer.from(
        // c0ffeee
        "07208e7ecf628e1095711165b8ef16d18539fa71b914042fec53d63c160c216c",
        "hex"
      )
    ),
  });
}
