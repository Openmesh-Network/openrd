import { Address, Deployer } from "../web3webdeploy/types";
import { DeployTasksSettings, deployTasks } from "./internal/Tasks";

export interface TasksDeploymentSettings {
  tasksSettings: DeployTasksSettings;
  forceRedeploy?: boolean;
}

export interface TasksDeployment {
  tasks: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: TasksDeploymentSettings
): Promise<TasksDeployment> {
  if (settings?.forceRedeploy !== undefined && !settings.forceRedeploy) {
    const existingDeployment = await deployer.loadDeployment({
      deploymentName: "latest.json",
    });
    if (existingDeployment !== undefined) {
      return existingDeployment;
    }
  }

  const tasks = await deployTasks(deployer, settings?.tasksSettings ?? {});

  const deployment: TasksDeployment = {
    tasks: tasks,
  };
  await deployer.saveDeployment({
    deploymentName: "latest.json",
    deployment: deployment,
  });
  return deployment;
}
