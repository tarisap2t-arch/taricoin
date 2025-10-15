
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const wallet1 = accounts.get("wallet_1")!;
const wallet2 = accounts.get("wallet_2")!;
const wallet3 = accounts.get("wallet_3")!;

const contractName = "taricoin";

describe("Taricoin Token Tests", () => {
  it("should initialize with correct metadata", () => {
    // Test token name
    const { result: name } = simnet.callReadOnlyFn(contractName, "get-name", [], deployer);
    expect(name).toBeOk("Taricoin");

    // Test token symbol
    const { result: symbol } = simnet.callReadOnlyFn(contractName, "get-symbol", [], deployer);
    expect(symbol).toBeOk("TARI");

    // Test token decimals
    const { result: decimals } = simnet.callReadOnlyFn(contractName, "get-decimals", [], deployer);
    expect(decimals).toBeOk(6);

    // Test max supply
    const { result: maxSupply } = simnet.callReadOnlyFn(contractName, "get-max-supply", [], deployer);
    expect(maxSupply).toBeOk(1000000000000000n);
  });

  it("should have initial supply minted to deployer", () => {
    const { result } = simnet.callReadOnlyFn(contractName, "get-balance", [deployer], deployer);
    expect(result).toBeOk(100000000000n); // 100,000 TARI with 6 decimals
  });

  it("should get correct total supply", () => {
    const { result } = simnet.callReadOnlyFn(contractName, "get-total-supply", [], deployer);
    expect(result).toBeOk(100000000000n);
  });

  it("should return correct contract owner", () => {
    const { result } = simnet.callReadOnlyFn(contractName, "get-contract-owner", [], deployer);
    expect(result).toBeOk(deployer);
  });

  it("should return token URI", () => {
    const { result } = simnet.callReadOnlyFn(contractName, "get-token-uri", [], deployer);
    expect(result).toBeOk("https://taricoin.com/metadata.json");
  });

  describe("Transfer functionality", () => {
    it("should successfully transfer tokens", () => {
      const transferAmount = 1000000n; // 1 TARI
      
      const { result } = simnet.callPublicFn(
        contractName,
        "transfer",
        [transferAmount, deployer, wallet1, "none"],
        deployer
      );
      expect(result).toBeOk(true);

      // Check balances after transfer
      const { result: deployerBalance } = simnet.callReadOnlyFn(
        contractName,
        "get-balance",
        [deployer],
        deployer
      );
      expect(deployerBalance).toBeOk(99999000000n);

      const { result: wallet1Balance } = simnet.callReadOnlyFn(
        contractName,
        "get-balance",
        [wallet1],
        wallet1
      );
      expect(wallet1Balance).toBeOk(1000000n);
    });

    it("should fail to transfer with invalid amount", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "transfer",
        [0n, deployer, wallet1, "none"],
        deployer
      );
      expect(result).toBeErr(103); // ERR_INVALID_AMOUNT
    });

    it("should fail to transfer from non-owner", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "transfer",
        [1000000n, deployer, wallet2, "none"],
        wallet1
      );
      expect(result).toBeErr(101); // ERR_NOT_TOKEN_OWNER
    });
  });

  describe("Minting functionality", () => {
    it("should allow owner to mint tokens", () => {
      const mintAmount = 5000000000n; // 5,000 TARI
      
      const { result } = simnet.callPublicFn(
        contractName,
        "mint",
        [mintAmount, wallet1],
        deployer
      );
      expect(result).toBeOk(true);

      // Check recipient balance
      const { result: balance } = simnet.callReadOnlyFn(
        contractName,
        "get-balance",
        [wallet1],
        wallet1
      );
      expect(balance).toBeOk(5001000000n); // Previous 1 TARI + 5,000 TARI

      // Check total supply increased
      const { result: totalSupply } = simnet.callReadOnlyFn(
        contractName,
        "get-total-supply",
        [],
        deployer
      );
      expect(totalSupply).toBeOk(105000000000n);
    });

    it("should prevent non-owner from minting", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "mint",
        [1000000n, wallet2],
        wallet1
      );
      expect(result).toBeErr(100); // ERR_OWNER_ONLY
    });

    it("should prevent minting invalid amount", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "mint",
        [0n, wallet1],
        deployer
      );
      expect(result).toBeErr(103); // ERR_INVALID_AMOUNT
    });
  });

  describe("Burning functionality", () => {
    it("should allow token holder to burn own tokens", () => {
      const burnAmount = 1000000n; // 1 TARI
      
      const { result } = simnet.callPublicFn(
        contractName,
        "burn",
        [burnAmount, wallet1],
        wallet1
      );
      expect(result).toBeOk(true);

      // Check balance decreased
      const { result: balance } = simnet.callReadOnlyFn(
        contractName,
        "get-balance",
        [wallet1],
        wallet1
      );
      expect(balance).toBeOk(5000000000n); // 5,001 - 1 = 5,000 TARI

      // Check total supply decreased
      const { result: totalSupply } = simnet.callReadOnlyFn(
        contractName,
        "get-total-supply",
        [],
        deployer
      );
      expect(totalSupply).toBeOk(104000000000n);
    });

    it("should prevent burning from non-owner", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "burn",
        [1000000n, wallet1],
        wallet2
      );
      expect(result).toBeErr(101); // ERR_NOT_TOKEN_OWNER
    });

    it("should prevent burning invalid amount", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "burn",
        [0n, wallet1],
        wallet1
      );
      expect(result).toBeErr(103); // ERR_INVALID_AMOUNT
    });
  });

  describe("Administrative functions", () => {
    it("should allow owner to set token URI", () => {
      const newUri = "https://newuri.com/metadata.json";
      
      const { result } = simnet.callPublicFn(
        contractName,
        "set-token-uri",
        [`"${newUri}"`],
        deployer
      );
      expect(result).toBeOk(true);

      // Verify URI was updated
      const { result: uri } = simnet.callReadOnlyFn(
        contractName,
        "get-token-uri",
        [],
        deployer
      );
      expect(uri).toBeOk(newUri);
    });

    it("should prevent non-owner from setting token URI", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "set-token-uri",
        [`"https://malicious.com"`],
        wallet1
      );
      expect(result).toBeErr(100); // ERR_OWNER_ONLY
    });

    it("should allow owner to transfer ownership", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "set-contract-owner",
        [wallet2],
        deployer
      );
      expect(result).toBeOk(true);

      // Verify ownership transferred
      const { result: newOwner } = simnet.callReadOnlyFn(
        contractName,
        "get-contract-owner",
        [],
        wallet2
      );
      expect(newOwner).toBeOk(wallet2);
    });

    it("should prevent non-owner from transferring ownership", () => {
      const { result } = simnet.callPublicFn(
        contractName,
        "set-contract-owner",
        [wallet3],
        wallet1
      );
      expect(result).toBeErr(100); // ERR_OWNER_ONLY
    });
  });
});
