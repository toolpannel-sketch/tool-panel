import mysql from "mysql2/promise";

const DATABASE_URL = 'mysql://2NEvSxPxfk2CGvT.root:ToolPanelPassword2026!@gateway01.us-east-1.prod.aws.tidbcloud.com:4000/test?ssl={"rejectUnauthorized":true}';

async function main() {
  const connection = await mysql.createConnection({
    uri: DATABASE_URL,
  });

  console.log("Checking current columns...");
  const [cols] = await connection.query("DESCRIBE licenses");
  const colNames = cols.map(c => c.Field);
  console.log("Columns before:", colNames);

  const renames = [
    ["durationMinutes", "duration_minutes", "int NULL"],
    ["maxDevices", "max_devices", "int NOT NULL DEFAULT '1'"],
    ["boundDeviceId", "bound_device_id", "varchar(128) NULL"],
    ["activatedAt", "activated_at", "timestamp NULL DEFAULT NULL"],
    ["expiresAt", "expires_at", "timestamp NULL DEFAULT NULL"],
    ["createdByUserId", "created_by_user_id", "int NULL"],
    ["createdAt", "created_at", "timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP"],
    ["updatedAt", "updated_at", "timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"],
  ];

  for (const [oldName, newName, typeDef] of renames) {
    if (colNames.includes(oldName)) {
      console.log(`Renaming ${oldName} -> ${newName}...`);
      await connection.query(`ALTER TABLE licenses CHANGE COLUMN \`${oldName}\` \`${newName}\` ${typeDef}`);
    }
  }

  const [colsAfter] = await connection.query("DESCRIBE licenses");
  console.log("Columns after:", colsAfter.map(c => c.Field));

  await connection.end();
}

main().catch(console.error);
