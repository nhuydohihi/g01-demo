import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// Deploy khai báo (declarative): deploy contract nào, với tham số gì.
// Ignition lưu kết quả vào ignition/deployments/<deployment-id>/ → commit thư mục đó.
export default buildModule("EventRegistryModule", (m) => {
  const capacity = m.getParameter("capacity", 100n);
  const registry = m.contract("EventRegistry", [capacity]);
  return { registry };
});
