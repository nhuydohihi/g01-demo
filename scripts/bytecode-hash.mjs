// In ra hash của bytecode đã compile để so sánh giữa các máy (kiểm tra reproducibility).
// Dùng: pnpm build:prod && pnpm bytecode:hash
import { readFileSync } from "node:fs";
import { createHash } from "node:crypto";

const a = JSON.parse(readFileSync("artifacts/contracts/EventRegistry.sol/EventRegistry.json", "utf8"));
const sha = (hex) => createHash("sha256").update(hex).digest("hex");
console.log("contract            :", a.contractName);
console.log("bytecode bytes      :", (a.bytecode.length - 2) / 2);
console.log("bytecode sha256     :", sha(a.bytecode));
console.log("deployedBytecode sha:", sha(a.deployedBytecode));
