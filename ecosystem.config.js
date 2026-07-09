module.exports = {
  apps: [
    {
      name: "multi-auth",
      script: "server.js",
      instances: 1,
      exec_mode: "fork",
      watch: false,
      autorestart: true,
      max_restarts: 10,
      env: {
        NODE_ENV: "production",
        PORT: 5000,
      },
    },
  ],
};