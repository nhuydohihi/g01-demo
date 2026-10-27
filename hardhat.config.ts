import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";

// Mọi thiết lập ảnh hưởng tới bytecode đều được ghi rõ ở đây (không dựa vào mặc định).
const SOLC_VERSION = "0.8.36";
const EVM_VERSION = "osaka";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  solidity: {
    profiles: {
      // Dùng khi phát triển và chạy test
      default: {
        version: SOLC_VERSION,
        settings: {
          evmVersion: EVM_VERSION,
        },
      },
      // Dùng khi deploy (Ignition) và verify
      production: {
        version: SOLC_VERSION,
        settings: {
          evmVersion: EVM_VERSION,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      // Bí mật lấy từ keystore: npx hardhat keystore set <TÊN>
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
  },
  verify: {
    etherscan: {
      apiKey: configVariable("ETHERSCAN_API_KEY"),
    },
  },
});
