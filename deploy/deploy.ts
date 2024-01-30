import { Address, Deployer } from "../web3webdeploy/types";
import { deployCounter } from "./counters/Counter";
import { deployProxyCounter } from "./counters/ProxyCounter";

export interface DeploymentSettings {
  startingNumber: bigint;
}

export interface Deployment {
  counter: Address;
  proxyCounter: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: DeploymentSettings
): Promise<Deployment> {
  const counter = await deployCounter(deployer);
  const proxyCounter = await deployProxyCounter(deployer, counter);
  await deployer.execute({
    id: "InitialCounterNumber",
    abi: "Counter",
    to: counter,
    function: "setNumber",
    args: [settings?.startingNumber ?? BigInt(3)],
  });
  return {
    counter: counter,
    proxyCounter: proxyCounter,
  };
}
