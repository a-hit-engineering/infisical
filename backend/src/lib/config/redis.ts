import { Redis } from "ioredis";

export type TRedisConfigKeys = Partial<{
  REDIS_URL: string;
  REDIS_SENTINEL_HOSTS: { host: string; port: number }[];
  REDIS_SENTINEL_MASTER_NAME: string;
  REDIS_SENTINEL_ENABLE_TLS: boolean;
  REDIS_SENTINEL_USERNAME: string;
  REDIS_SENTINEL_PASSWORD: string;
  REDIS_TLS_ENABLED: boolean;
  REDIS_TLS_REJECT_UNAUTHORIZED: boolean;
  REDIS_TLS_SNI_SERVERNAME: string;
  REDIS_TLS_CA_CERT: string;
  TLS_REJECT_UNAUTHORIZED: boolean;
}>;

export const buildRedisFromConfig = (cfg: TRedisConfigKeys) => {
  if (cfg.REDIS_URL) {
    const redisOptions: any = {
      maxRetriesPerRequest: null
    };

    if (cfg.REDIS_TLS_ENABLED || cfg.REDIS_URL.startsWith("rediss://")) {
      const tlsOptions: any = {
        rejectUnauthorized: cfg.REDIS_TLS_REJECT_UNAUTHORIZED !== false
      };

      if (cfg.REDIS_TLS_SNI_SERVERNAME) {
        tlsOptions.servername = cfg.REDIS_TLS_SNI_SERVERNAME;
      }

      if (cfg.REDIS_TLS_CA_CERT) {
        try {
          tlsOptions.ca = Buffer.from(cfg.REDIS_TLS_CA_CERT, "base64").toString("utf-8");
        } catch (err) {
          console.warn("Failed to decode Redis TLS CA certificate:", err);
        }
      }

      if (cfg.TLS_REJECT_UNAUTHORIZED === false) {
        tlsOptions.rejectUnauthorized = false;
        console.log("🔓 Redis TLS certificate verification disabled for development");
      }

      redisOptions.tls = tlsOptions;
    }

    return new Redis(cfg.REDIS_URL, redisOptions);
  }

  const sentinelOptions: any = {
    sentinels: cfg.REDIS_SENTINEL_HOSTS!,
    name: cfg.REDIS_SENTINEL_MASTER_NAME!,
    maxRetriesPerRequest: null,
    sentinelUsername: cfg.REDIS_SENTINEL_USERNAME,
    sentinelPassword: cfg.REDIS_SENTINEL_PASSWORD,
    enableTLSForSentinelMode: cfg.REDIS_SENTINEL_ENABLE_TLS
  };

  if (cfg.REDIS_TLS_ENABLED && cfg.REDIS_SENTINEL_ENABLE_TLS) {
    const tlsOptions: any = {
      rejectUnauthorized: cfg.REDIS_TLS_REJECT_UNAUTHORIZED !== false
    };

    if (cfg.REDIS_TLS_SNI_SERVERNAME) {
      tlsOptions.servername = cfg.REDIS_TLS_SNI_SERVERNAME;
    }

    if (cfg.REDIS_TLS_CA_CERT) {
      try {
        tlsOptions.ca = Buffer.from(cfg.REDIS_TLS_CA_CERT, "base64").toString("utf-8");
      } catch (err) {
        console.warn("Failed to decode Redis TLS CA certificate for sentinel:", err);
      }
    }

    if (cfg.TLS_REJECT_UNAUTHORIZED === false) {
      tlsOptions.rejectUnauthorized = false;
    }

    sentinelOptions.tls = tlsOptions;
  }

  return new Redis(sentinelOptions);
};
