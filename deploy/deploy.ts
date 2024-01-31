import { Address, Deployer } from "../web3webdeploy/types";

export interface TasksDeploymentSettings {
  disabler?: Address;
}

export interface TasksDeployment {
  tasks: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: TasksDeploymentSettings
): Promise<TasksDeployment> {
  const disabler =
    settings?.disabler ?? "0x2309762aAcA0a8F689463a42c0A6A84BE3A7ea51";
  const tasks = await deployer.deploy({
    id: "Tasks",
    contract: "Tasks",
    args: [disabler],
  });
  return {
    tasks: tasks,
  };
}
