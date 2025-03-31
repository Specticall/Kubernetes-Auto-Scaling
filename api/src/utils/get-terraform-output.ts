import { execa } from "execa";
import { TERRAFORM_DIR_PATH, TERRAFORM_OUTPUT_NAME } from "../config/config";
import { logger } from "./logger";
import { z } from "zod";

export default async function getTerraformOutput<T extends z.ZodTypeAny>(
  name: string,
  schema: T
) {
  try {
    const { stdout, stderr } = await execa(
      "terraform",
      ["output", "-json", name],
      {
        cwd: TERRAFORM_DIR_PATH,
      }
    );
    if (stderr) {
      throw new Error(stderr);
    }
    const rawOutput = JSON.parse(stdout);
    return schema.parse(rawOutput) as z.infer<T>;
  } catch (error: unknown) {
    if (!(error instanceof Error)) {
      throw new Error("Oops something went wrong!");
    }

    // Log the error for debugging
    console.error("Error extracting Terraform output:", error.message);

    // Throw a meaningful error
    throw new Error(
      `Failed to extract Terraform output for '${TERRAFORM_OUTPUT_NAME}'. Ensure Terraform is installed, the directory is correct, and the output exists.`
    );
  }
}
