import { Address, DeployInfo, Deployer } from "../web3webdeploy/types";

export interface TasksDeploymentSettings
  extends Omit<DeployInfo, "contract" | "args"> {}

export interface TasksDeployment {
  tasks: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: TasksDeploymentSettings
): Promise<TasksDeployment> {
  const tasks = await deployer.deploy({
    id: "Tasks",
    contract: "Tasks",
    ...settings,
  });

  const deployment = {
    tasks: tasks,
  };
  await deployer.saveDeployment({
    deploymentName: "latest.json",
    deployment: deployment,
  });
  return deployment;
}
