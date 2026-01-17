import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  /* config options here */
  // Explicitly set the project root to prevent Next.js from detecting parent directory
  experimental: {
    outputFileTracingRoot: path.join(__dirname),
  },
  // Use webpack to fix module resolution for tailwindcss
  webpack: (config, { isServer }) => {
    // Set the context to the backend directory to ensure correct module resolution
    config.context = __dirname;
    
    // Ensure modules resolve from backend node_modules first
    if (config.resolve) {
      config.resolve.modules = [
        path.resolve(__dirname, 'node_modules'),
        ...(Array.isArray(config.resolve.modules) ? config.resolve.modules : ['node_modules']),
      ];
      
      // Also set resolveLoader to ensure loaders resolve from correct directory
      if (!config.resolveLoader) {
        config.resolveLoader = {};
      }
      config.resolveLoader.modules = [
        path.resolve(__dirname, 'node_modules'),
        ...(Array.isArray(config.resolveLoader.modules) ? config.resolveLoader.modules : ['node_modules']),
      ];
    }
    return config;
  },
};

export default nextConfig;
