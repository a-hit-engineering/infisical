/**
 * OrbStack Compatibility Module
 *
 * OrbStack uses self-signed certificates for local HTTPS connections,
 * which causes Node.js to reject the connection by default.
 * This module provides utilities to handle this in development environments.
 */

import { getConfig } from "./config/env";

export const initOrbStackCompatibility = () => {
  const config = getConfig();

  // Only disable TLS verification in development mode
  if (config.isDevelopmentMode) {
    // Check if we're likely running in OrbStack
    const isOrbStack =
      process.env.CONTAINER_RUNTIME === "orbstack" ||
      process.env.DOCKER_HOST?.includes("orbstack") ||
      process.platform === "darwin"; // macOS is primary OrbStack platform

    if (isOrbStack && config.TLS_REJECT_UNAUTHORIZED === false) {
      process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
      console.log("🔓 TLS certificate verification disabled for OrbStack compatibility");

      // Also configure axios defaults if available
      if (typeof global !== "undefined") {
        // @ts-ignore
        global.INFISICAL_ORBSTACK_MODE = true;
      }
    }
  }
};

/**
 * Create an HTTPS agent that accepts self-signed certificates
 * for use with OrbStack
 */
export const createOrbStackHttpsAgent = () => {
  const https = require("https");
  const config = getConfig();

  if (config.isDevelopmentMode) {
    return new https.Agent({
      rejectUnauthorized: false
      // Add other OrbStack-specific configurations if needed
    });
  }

  // Return default agent for production
  return new https.Agent();
};
