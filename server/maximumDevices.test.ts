import { describe, expect, it } from "vitest";
import { isValidMaximumDevices, MAX_LICENSE_DEVICES } from "./license";
import { maximumDevicesInput } from "./routers";

describe("Maximum Devices validation", () => {
  it.each([100, 400, 1000, 10000])("accepts %i in service and API input validation", value => {
    expect(isValidMaximumDevices(value)).toBe(true);
    expect(maximumDevicesInput.safeParse(value).success).toBe(true);
  });

  it("rejects 10001 in service and API input validation", () => {
    expect(MAX_LICENSE_DEVICES).toBe(10_000);
    expect(isValidMaximumDevices(10001)).toBe(false);
    expect(maximumDevicesInput.safeParse(10001).success).toBe(false);
  });
});
