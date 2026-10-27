# G01 Demo — Reproducible & safe Solidity 0.8.36 + Hardhat 3 workflow

IS355 · Session 7 · G01. Demo cho câu hỏi: *What makes a smart-contract workflow reproducible and safe enough for a public testnet?*

Contract demo: `EventRegistry` — owner tạo một sự kiện có sức chứa giới hạn, người dùng tự đăng ký. Đủ nhỏ để đọc trên một slide, nhưng có access control, custom errors, events và checks-effects.

## 1. Phiên bản đã pin

| Thành phần | Phiên bản | Pin ở đâu |
| --- | --- | --- |
| Solidity (solc) | 0.8.36 | `pragma solidity 0.8.36;` + `hardhat.config.ts` |
| EVM target | osaka | `hardhat.config.ts` (ghi rõ, không dùng mặc định) |
| Optimizer (profile production) | enabled, runs 200 | `hardhat.config.ts` |
| Hardhat | 3.21.0 | `package.json` (không `^`) + `pnpm-lock.yaml` |
| hardhat-toolbox-viem | 5.0.7 | như trên |
| hardhat-ignition | 3.1.9 | như trên |
| viem | 2.57.11 | như trên |
| forge-std | v1.16.2 (git tag) | `package.json` |
| Node.js | 24.11.1 (tối thiểu 22.13.0) | `.nvmrc` + `engines` |
| pnpm | 12.15.0 | `packageManager` trong `package.json` |

## 2. Lệnh

| Việc | Lệnh | Bằng chứng (đề bài) |
| --- | --- | --- |
| Cài đặt đúng lockfile | `pnpm install --frozen-lockfile` | version/dependency pinning |
| Compile (deploy profile) | `pnpm build:prod` | compile |
| Hash bytecode để so giữa các máy | `pnpm bytecode:hash` | reproducibility |
| Unit test (happy, revert, event, fuzz) | `pnpm test:sol` | unit test |
| Failure trace (test cố ý fail) | `pnpm test:trace` | failure trace |
| Deploy mạng giả lập | `pnpm deploy:local` | deployment |
| Deploy Sepolia | `pnpm deploy:sepolia` | deployment |
| Verify Etherscan | `pnpm verify:sepolia <ĐỊA_CHỈ> 100` | deployment |

Output thật của từng lệnh nằm trong thư mục `evidence/`.

## 3. Cấu trúc

```
contracts/EventRegistry.sol        contract
contracts/EventRegistry.t.sol      10 unit test (2 fuzz × 256 runs)
test/FailureTraceDemo.t.sol        test cố ý fail, mặc định skip; bật bằng DEMO_FAIL=true
ignition/modules/EventRegistry.ts  module deploy (tham số capacity = 100)
scripts/bytecode-hash.mjs          in sha256 của bytecode
evidence/                          output đã chạy
RUN_ON_MAC.md                      các bước còn lại phải chạy trên máy có key
```

## 4. Bí mật

Không có bí mật nào trong repo. `hardhat.config.ts` chỉ ghi **tên** biến (`configVariable`):

- `SEPOLIA_RPC_URL`
- `SEPOLIA_PRIVATE_KEY` — ví riêng cho testnet
- `ETHERSCAN_API_KEY`

Giá trị được lưu mã hóa bằng `npx hardhat keystore set <TÊN>`, nằm ngoài repo.

## 5. Bản ghi deployment (điền sau khi deploy Sepolia)

| Trường | Giá trị |
| --- | --- |
| Network | Sepolia |
| Chain ID | 11155111 |
| Contract address | _(điền)_ |
| Deploy tx hash | _(điền)_ |
| Deployer (admin/owner) | _(điền — chính là ví deploy)_ |
| Constructor arg `capacity` | 100 |
| Build profile | production |
| Etherscan (verified) | _(điền link)_ |
| Git commit | _(điền `git rev-parse --short HEAD`)_ |

Ignition tự lưu bản ghi chi tiết trong `ignition/deployments/chain-11155111/` → commit thư mục này.

## 6. Giả định và sai khác so với mặc định (ghi rõ, không áp dụng ngầm)

1. Template `hardhat --init` (node-test-runner-viem, Hardhat 3.21.1) mặc định dùng solc **0.8.34** → đổi thành **0.8.36** theo môn học.
2. Template ghi dependency dạng `^x.y.z` → đổi thành phiên bản chính xác đã được cài.
3. `evmVersion` ghi rõ `osaka` (giá trị Hardhat báo là target khi build với 0.8.36) thay vì để mặc định. Cần đảm bảo mạng đích hỗ trợ Osaka; nếu deploy lỗi opcode, đổi sang `prague` và ghi lại lý do.
4. Bỏ file mẫu (`Counter.*`, `scripts/send-op-tx.ts`, mạng `hardhatOp`) và các file agent do template sinh (`AGENTS.md`, `.agents/`) để repo chỉ chứa phần demo.
5. Test failure trace được đặt trong `test/` nhưng skip mặc định (`vm.skip(!vm.envOr("DEMO_FAIL", false))`) để `pnpm test` luôn xanh.
6. Project được dựng và chạy lần đầu trên Linux arm64 / Node 22.23.4, nơi solc không có bản native nên Hardhat dùng **bản WASM** của solc 0.8.36. Trên macOS, Hardhat dùng bản native. Hai bản cùng phiên bản phải cho **cùng bytecode** — kiểm tra bằng `pnpm bytecode:hash` và so với `evidence/01b-bytecode-hash.txt`.
