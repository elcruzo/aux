import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  async rewrites() {
    return [
      {
        source: '/swagger.json',
        destination: '/api/docs',
      },
    ];
  },
};

export default nextConfig;
