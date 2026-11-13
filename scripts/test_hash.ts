import 'dotenv/config';
import { hashDevice } from '../server/license';

const candidates = [
  "test_device_1",
  "unknown",
  "",
  "device_id",
  "123456",
  "0000000000000000"
];

for (const c of candidates) {
  const h = hashDevice(c);
  console.log(c, "->", h);
}
