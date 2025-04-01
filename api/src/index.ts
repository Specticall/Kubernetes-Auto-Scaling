import chalk from "chalk";
import app from "./app";
import { API_PORT } from "./config/config";

/**
 * Start the server instance
 */
app.listen(API_PORT, () => {
  console.log(`${chalk.blue("[SERVER]")} Running on port ${API_PORT}`);
});
