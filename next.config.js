const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development'
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['a-static.mlcdn.com.br', 'www.magazineluiza.com.br', 'www.magazinevoce.com.br'],
    unoptimized: true,
  },
};

module.exports = withPWA(nextConfig);
