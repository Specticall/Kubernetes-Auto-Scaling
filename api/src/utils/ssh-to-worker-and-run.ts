import { execa } from "execa";
import replaceRootAliasToAbsolutePath from "./replace-root-alias-to-absolute-path";
import {
  NODE_VM_ADMIN_USERNAME,
  NODE_VM_SSH_PRIVATE_KEY_PATH,
} from "../config/config";

/**
 * SSH to worker with a jump through the bastion server then run a specified command
 */
export default async function sshToWorkerAndRun(
  bastionIp: string,
  workerIp: string,
  args: string[]
) {
  return execa(
    "ssh",
    [
      "-i",
      replaceRootAliasToAbsolutePath(NODE_VM_SSH_PRIVATE_KEY_PATH),
      // Use SSH Agent Forwarding
      "-A",
      // Use bastion to proxy jump
      "-J",
      `bastion@${bastionIp}`,
      `${NODE_VM_ADMIN_USERNAME}@${workerIp}`,
      "-o",
      "StrictHostKeyChecking=no",
      "-o",
      "UserKnownHostsFile=/dev/null",
      ...args,
    ],
    { reject: false }
  );
}
