# Các bước chạy trên Mac (phần cần key của bạn)

Mở Terminal, tắt conda trước:

```bash
conda deactivate
cd ~/bc_dev/g01-demo
```

## 1. Cài đặt đúng lockfile

```bash
pnpm install --frozen-lockfile
```

`node_modules` được cài lại cho macOS (Hardhat có thành phần native riêng cho mỗi hệ điều hành). Lockfile giữ nguyên phiên bản.

## 2. Kiểm tra reproducibility — so bytecode

```bash
pnpm build:prod
pnpm bytecode:hash
```

So hai dòng `sha256` với file `evidence/01b-bytecode-hash.txt`:

```
bytecode sha256     : 7c57faea25b1208acc8f7fcab4d36fc025c91c083b535abcfc92e6a6bc9dd4f1
deployedBytecode sha: b607aba8acb097e182b1a23be825fe5a07a8c0d2edc5f1cdf3d5438bcf09310b
```

- **Giống hệt** → bằng chứng mạnh nhất cho "reproducible": hai máy, hai hệ điều hành, hai bản build solc (native vs WASM), cùng bytecode. Chụp màn hình cho slide.
- **Khác** → báo lại cho Claude, kèm output; đừng sửa gì trước.

## 3. Chạy test và failure trace (chụp màn hình)

```bash
pnpm test:sol      # kỳ vọng: 10 passing, 1 skipped
pnpm test:trace    # kỳ vọng: 1 failing, trace có NotOwner(0x...B0b)
```

## 4. Cất bí mật vào keystore

Lần đầu Hardhat sẽ hỏi tạo mật khẩu keystore — nhớ mật khẩu này.

```bash
npx hardhat keystore set SEPOLIA_RPC_URL
# dán: https://ethereum-sepolia-rpc.publicnode.com

npx hardhat keystore set SEPOLIA_PRIVATE_KEY
# dán private key của ví TESTNET (MetaMask → Account details → Show private key)

npx hardhat keystore set ETHERSCAN_API_KEY
# dán API key Etherscan

npx hardhat keystore list   # chụp màn hình: chỉ thấy TÊN, không thấy giá trị
```

## 5. Deploy lên Sepolia

```bash
pnpm deploy:sepolia
```

Nhập mật khẩu keystore, gõ `y` để xác nhận. Ghi lại địa chỉ ở dòng `EventRegistryModule#EventRegistry - 0x...`.

## 6. Verify trên Etherscan

Đợi khoảng 1 phút sau khi deploy, rồi:

```bash
pnpm verify:sepolia <ĐỊA_CHỈ_CONTRACT> 100
```

(`100` là tham số `capacity` trong constructor.) Cách khác, tự lấy tham số từ bản ghi Ignition:

```bash
npx hardhat ignition verify chain-11155111
```

Mở `https://sepolia.etherscan.io/address/<ĐỊA_CHỈ>` → tab Contract → chụp dấu **Verified**.

## 7. Ghi bản ghi deployment và commit

1. Điền bảng mục 5 trong `README.md` (địa chỉ, tx hash, link Etherscan, commit).
2. Commit:

```bash
git add README.md ignition/deployments
git commit -m "deploy: EventRegistry to Sepolia (chain 11155111), verified"
```

## Nếu gặp lỗi

| Lỗi | Thử |
| --- | --- |
| `insufficient funds` | Ví hết Sepolia ETH → xin thêm ở faucet |
| Lỗi liên quan RPC / timeout | Chạy lại; hoặc đổi `SEPOLIA_RPC_URL` sang Infura |
| Verify báo chưa tìm thấy contract | Đợi 1–2 phút rồi chạy lại |
| Lỗi opcode / invalid opcode khi deploy | Đổi `EVM_VERSION` trong `hardhat.config.ts` thành `"prague"`, chạy lại từ bước 2, ghi lý do vào README |

Bất kỳ lỗi nào khác: dán nguyên output cho Claude.
