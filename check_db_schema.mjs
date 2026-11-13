import mysql from "mysql2/promise";

const DATABASE_URL = 'mysql://2NEvSxPxfk2CGvT.root:ToolPanelPassword2026!@gateway01.us-east-1.prod.aws.tidbcloud.com:4000/test?ssl={"rejectUnauthorized":true}';

async function main() {
  const connection = await mysql.createConnection({
    uri: DATABASE_URL,
  });

  const [cols] = await connection.query("DESCRIBE licenses");
  console.log("Licenses Columns in TiDB:", cols.map(c => c.Field));

  await connection.end();
}

main().catch(console.error);
