import { z } from "zod";
import { RABBIT_MQ_URL } from "../config/config";
import { logger } from "../utils";
import { MessageQueue } from "../utils/message-broker/message-queue";
import { QUEUE_NAMES } from "../utils/message-broker/queue-names";
import scaleWorker from "../core/scale-worker";

const messageQueue = new MessageQueue(RABBIT_MQ_URL, QUEUE_NAMES.SCALER);

const scalerRequestBodySchema = z.object({
  target_vm_count: z.number().nonnegative(),
});

async function startConsumer() {
  logger.info("Starting scaler consumer, please wait...");
  await messageQueue.connect();
  logger.info("Successfuly started scaler consumer");

  messageQueue.addConsumerListener(async (message) => {
    try {
      logger.info(`Scaling vm, please wait...`);

      const data = scalerRequestBodySchema.parse(JSON.parse(message));
      await scaleWorker(data.target_vm_count);

      logger.success(`Successfuly scaled vm to ${data.target_vm_count}`);
    } catch (err) {
      logger.error(`Failed to parse messages ${(err as Error).message}`);
    }
  });
}

startConsumer();
