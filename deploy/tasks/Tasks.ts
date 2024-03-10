import { Address, DeployInfo, Deployer } from "../../web3webdeploy/types";

export interface DeployTasksSettings
  extends Omit<DeployInfo, "contract" | "args"> {}

export async function deployTasks(
  deployer: Deployer,
  settings: DeployTasksSettings
): Promise<Address> {
  return await deployer
    .deploy({
      id: "Tasks",
      contract: "Tasks",
      ...settings,
    })
    .then((deployment) => deployment.address);
}
