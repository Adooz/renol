Deploying renol (Django) to an Ubuntu 22 VPS (Hostinger)

This README explains a minimal, repeatable way to deploy the `renol` repo to an Ubuntu 22 server.

What this provides
- A bash script at `deploy/ubuntu_deploy.sh` that installs runtime packages, creates a system user, sets up a venv, installs requirements, runs migrations, creates a systemd service for gunicorn, and configures nginx.
- Example `gunicorn.service` and `nginx` config files in `deploy/` and a `.env` example.

Quick local test (on your local Ubuntu 22 machine)
1. Copy the project root to your Ubuntu machine or clone the repo.
2. From project root, run the script with the `--local` flag so it copies the current files:

   sudo bash deploy/ubuntu_deploy.sh --local --domain YOUR_SERVER_IP_OR_DOMAIN

3. After the script completes, visit `http://YOUR_SERVER_IP_OR_DOMAIN`.

On the VPS (Hostinger) — recommended steps
1. SSH into your VPS.
2. Install updates and re-run the deploy script (use `--repo` to clone directly):

   sudo bash deploy/ubuntu_deploy.sh --repo https://github.com/youruser/renol.git --branch main --domain yourdomain.com

3. Generate a secure `SECRET_KEY` and replace `SECRET_KEY` in `/opt/renol/app/.env`. Also update any other env values (DB, email credentials, etc.).
4. Enable HTTPS: After nginx serves the site, use Certbot to get a certificate and reload nginx:

   sudo apt install -y certbot python3-certbot-nginx
   sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

Notes & assumptions
- The script assumes you want Postgres. If you need MySQL (Hostinger often offers MySQL), set `PRODUCTION=True` and populate `DB_*` env vars in `.env` and update `DATABASE_URL` accordingly.
- The script uses `gunicorn` and systemd with unix socket `/run/renol.sock`.
- It writes a simple `.env` that `python-dotenv` will load (your `paylio/settings.py` already uses `load_dotenv()`).

Security checklist (post-deploy)
- Replace the `SECRET_KEY` with a secure, random value.
- Create a real DB user/password and remove the example `renolpass`.
- Configure firewall: `ufw allow OpenSSH; ufw allow 'Nginx Full'; ufw enable`.

If you want, I can:
- Customize the script to use MySQL (if you prefer Hostinger's managed MySQL).
- Add a small Ansible playbook for repeatable deployments.
- Add a makefile or system health checks.

Docker note (Railway uses Docker)
--------------------------------
This repository contains a `Dockerfile` and `startup.sh` that Railway used to build and run the app. If you prefer to deploy the exact same container on your Ubuntu VPS, use the provided `deploy/docker_deploy.sh` script. It will:

- Install Docker Engine and the compose plugin if missing.
- Clone (or copy) the repo, build the Docker image using the included `Dockerfile`.
- Run the container (mapped to localhost:8080) and configure nginx as a reverse proxy.

Quick Docker deploy example (on the VPS):

   sudo bash deploy/docker_deploy.sh --repo https://github.com/Adooz/renol.git --branch main --domain yourdomain.com

Or to test locally (copy current workspace):

   sudo bash deploy/docker_deploy.sh --local --domain 127.0.0.1

After deployment, optionally obtain TLS with certbot as shown earlier.

