import getTerraformOutput from "./utils/scaler/get-terraform-output";
import runTerraformApply from "./utils/scaler/run-terraform-apply";
import setupNodeVMWithAnsible from "./utils/scaler/setup-node-vm-with-ansible";
import z from "zod";
import startSSHAgent from "./utils/scaler/start-ssh-agent";
import joinNodes from "./utils/scaler/join-nodes";
import modifyVMConfig from "./utils/scaler/modify-vm-config";
import fs from "fs/promises";
import { TERRAFORM_DIR_PATH } from "./config/config";
import detachWorkers from "./utils/scaler/detach-worker";
import { logger } from "./utils";

const vmIpSchema = z.record(z.string(), z.string());
export type VMIps = z.infer<typeof vmIpSchema>;

async function scale() {
  try {
    // TEMP : Input comes from API body / prometheus logging
    const targetVMCount = process.argv[2];

    // Create terraform configuration file
    logger.info("Updating terraform config file, please wait...");
    const { newWorkersConfig, removedVMs } = await modifyVMConfig(
      Number(targetVMCount)
    );
    const newTerraformConfig = {
      workers_config: Object.fromEntries(newWorkersConfig),
    };
    await fs.writeFile(
      `${TERRAFORM_DIR_PATH}/terraform.tfvars.json`,
      JSON.stringify(newTerraformConfig, null, "\t"),
      "utf-8"
    );
    logger.success("Sucessfully updated terraform config file");
    logger.break();

    // Ensure agent is running
    logger.info("Starting SSH agent, please wait...");
    await startSSHAgent();
    logger.success("Successfuly started SSH agent");
    logger.break();

    // Drain & Remove unused worker vms
    if (removedVMs.length > 0) {
      logger.info("Removing vms from the cluster, please wait...");
      await detachWorkers(removedVMs);
      logger.success("Successfuly detached workers from the cluster");
      logger.break();
    }

    // Execute terraform
    logger.info("Updating terraform state, please wait...");
    await runTerraformApply();
    logger.success("Successfuly provisined desired state");
    logger.break();

    // Retrieve terraform output
    logger.info("Retrieving vm ips from terraform state, please wait...");
    const [vmIpList, bastionIpList] = await Promise.all([
      getTerraformOutput("vms", vmIpSchema),
      getTerraformOutput("bastion_public_ip", vmIpSchema),
    ]);
    const bastionIp = Object.values(bastionIpList)[0];
    if (!bastionIp) {
      throw new Error("Bastion ip does not exist");
    }
    logger.success("Successfuly retrieved vm ips");
    logger.break();

    if (removedVMs.length === 0) {
      // Configure VM and setup k8s dependencies
      logger.info("Configuring vms using ansible playbook, please wait...");
      await setupNodeVMWithAnsible(vmIpList, bastionIp);
      logger.success("Successfuly configured vms");
      logger.break();

      logger.info("Joining provisioned nodes into the cluster, please wait...");
      await joinNodes(vmIpList, bastionIp);
      logger.success("Successfuly joined nodes to the cluster");
      logger.break();
    }

    logger.success("Successfuly scaled the kubernetes worker nodes");
  } catch (err) {
    console.log(err);
  }
}
scale();
