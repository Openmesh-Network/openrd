import { Address, Deployer } from "../web3webdeploy/types";
import { deploy as openmeshAdminDeploy } from "../lib/openmesh-admin/deploy/deploy";
import { deploy as ensReverseRegistrarDeploy } from "../lib/ens-reverse-registrar/deploy/deploy";

export interface TasksDeploymentSettings {
  admin?: Address;
  ensReverseRegistrar?: Address;
}

export interface TasksDeployment {
  tasks: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: TasksDeploymentSettings
): Promise<TasksDeployment> {
  deployer.startContext("lib/openmesh-admin");
  const admin = settings?.admin ?? (await openmeshAdminDeploy(deployer)).admin;
  deployer.finishContext();
  deployer.startContext("lib/ens-reverse-registrar");
  const ensReverseRegistrar =
    settings?.ensReverseRegistrar ??
    (await ensReverseRegistrarDeploy(deployer)).reverseRegistrar;
  deployer.finishContext();
  const tasks = await deployer.deploy({
    id: "Tasks",
    contract: "Tasks",
    args: [admin, ensReverseRegistrar],
  });
  return {
    tasks: tasks,
  };
}
