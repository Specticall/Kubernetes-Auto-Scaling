import { RequestHandler } from "express";
import z from "zod";
import { validateSchema } from "../utils/http/validate-schema";
import { AppError } from "../utils/http/app-error";
import { STATUS } from "../utils/http/status-codes";
import scaleWorker from "../core/scaleWorker";

const bodySchema = z.object({
  target_vm_count: z.number().nonnegative(),
});

export const scale: RequestHandler = async (request, response, next) => {
  try {
    // INFO : Prometheus logging
    if (!request.body) {
      throw new AppError("Request body not found", STATUS.NOT_FOUND);
    }
    const { target_vm_count: targetVMCount } = validateSchema(
      bodySchema,
      request.body
    );

    scaleWorker(targetVMCount);

    response.send({
      message: "Successfuly started scale process",
    });
  } catch (error) {
    next(error);
  }
};
