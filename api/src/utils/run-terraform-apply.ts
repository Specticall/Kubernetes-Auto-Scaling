import { execa } from "execa";
import { TERRAFORM_DIR_PATH } from "../config/config";
import chalk from "chalk";

export default async function runTerraformApply() {
  const terraform = execa("terraform", ["apply", "-auto-approve"], {
    cwd: TERRAFORM_DIR_PATH,
  });

  const handleStreamOutput = (data: unknown) => {
    // Print without new line
    process.stdout.write(`${chalk.magenta("[TERRAFORM]")} ${data?.toString()}`);
  };

  // Handle terraform data stream
  terraform.stdout.on("data", handleStreamOutput);
  terraform.stderr.on("data", handleStreamOutput);

  return terraform;
}
