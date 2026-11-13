# TOOL PANEL - 100% FREE DEPLOYMENT GUIDE (24/7 ONLINE)

Follow these steps to deploy your **TOOL PANEL** for free on **Render** with **TiDB Cloud** and keep it running 24/7 using a free cron job ping.

---

## STEP 1: FREE DATABASE SETUP (TiDB Cloud - 24/7 Free)

1. Open [https://tidbcloud.com](https://tidbcloud.com) and sign in with Google/Gmail.
2. Click **Create Cluster** and select **Serverless (Free $0)**.
3. Once the cluster is ready:
   - Click **Chat2Query** or **SQL Editor** from the left navigation.
   - Open `clean_database.sql` from your project folder, copy all text, paste it into SQL Editor, and click **Run**.
   - *(If you want to restore old keys & users instead, paste `database_dump.sql` instead).*
4. Click **Connect**:
   - Choose **Node.js** or **General MySQL**.
   - Generate password and copy the connection string.
   - Example:
     ```text
     mysql://3Bxxxxxxxx.root:PasswordHere@gateway01.us-east-1.prod.aws.tidbcloud.com:4000/test?ssl={"rejectUnauthorized":true}
     ```

---

## STEP 2: PUSH CODE TO GITHUB

1. Open [https://github.com/new](https://github.com/new) and create a new repository (e.g. `tool-panel`), set it to **Private** or **Public**.
2. Upload or push all project files from `license-panel` to this GitHub repository.

---

## STEP 3: DEPLOY ON RENDER (Free Web Service)

1. Open [https://render.com](https://render.com) and log in with GitHub.
2. Click **New +** (top right) -> Select **Web Service**.
3. Choose **Build and deploy from a Git repository** and connect your new repository.
4. Fill in the deployment details:
   - **Name**: `tool-panel` (or any custom name)
   - **Region**: Choose closest to you (e.g., Singapore or Frankfurt or Oregon)
   - **Branch**: `main`
   - **Root Directory**: *(leave blank)*
   - **Runtime**: `Node`
   - **Build Command**: `pnpm install && pnpm build`
   - **Start Command**: `pnpm start`
   - **Instance Type**: **Free**
5. Add **Environment Variables** (under the "Environment" tab):
   - `DATABASE_URL` = *(Your TiDB connection string from Step 1)*
   - `JWT_SECRET` = *(Any random string, e.g. `toolpanel-secret-token-key-2026`)*
   - `OWNER_OPEN_ID` = `super-owner-admin`
   - `OWNER_NAME` = `admin`
   - `NODE_ENV` = `production`
   - `PORT` = `3000`
6. Click **Deploy Web Service**!
   - In 2-3 minutes, your panel will be live at:
     `https://<your-service-name>.onrender.com`

---

## STEP 4: KEEP ALIVE 24/7 (Free Cron Job Ping)

Render free tier goes to sleep after 15 minutes of inactivity. To keep your panel active 24/7 without sleeping:

1. Open [https://cron-job.org](https://cron-job.org) or [https://uptimerobot.com](https://uptimerobot.com) (Both free).
2. Create a free account and click **Create Cronjob** / **Add New Monitor**.
3. Set the target URL to your panel's health endpoint:
   ```text
   https://<your-service-name>.onrender.com/health
   ```
4. Set execution interval: **Every 5 minutes**.
5. Save the cron job!
   - Now a ping is sent every 5 minutes, keeping Render awake 24 hours a day, 7 days a week!

---

## DEFAULT SUPER OWNER CREDENTIALS
- **Username**: `admin`
- **Password**: `admin123`
- *(You can change your password/username anytime in the dashboard or create new Admin/Owner referral codes).*
