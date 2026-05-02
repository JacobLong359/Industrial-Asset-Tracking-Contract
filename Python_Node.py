# -------------------------
# CONFIG
# -------------------------
RPC_URL = "ENTER YOUR RPC URL HERE"
CONTRACT_ADDRESS = "ENTER YOUR CONTRACT ADDRESS HERE"  # <-- paste your deployed contract address

# -------------------------
# CONTRACT ABI

# -------------------------
CONTRACT_ABI = [
  {
    "inputs": [],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "", "type": "address" }
    ],
    "name": "userRoles",
    "outputs": [
      { "internalType": "uint8", "name": "", "type": "uint8" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "nextAssetId",
    "outputs": [
      { "internalType": "uint256", "name": "", "type": "uint256" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      { "internalType": "address", "name": "", "type": "address" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "uint256", "name": "", "type": "uint256" }
    ],
    "name": "assets",
    "outputs": [
      { "internalType": "uint256", "name": "id", "type": "uint256" },
      { "internalType": "string", "name": "rfid", "type": "string" },
      { "internalType": "string", "name": "name", "type": "string" },
      { "internalType": "uint8", "name": "assetType", "type": "uint8" },
      { "internalType": "uint8", "name": "location", "type": "uint8" },
      { "internalType": "uint8", "name": "availability", "type": "uint8" },
      { "internalType": "address", "name": "createdBy", "type": "address" },
      { "internalType": "bool", "name": "exists", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "string", "name": "", "type": "string" }
    ],
    "name": "rfidToAssetId",
    "outputs": [
      { "internalType": "uint256", "name": "", "type": "uint256" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "string", "name": "rfid", "type": "string" }
    ],
    "name": "getAssetByRFID",
    "outputs": [
      { "internalType": "uint256", "name": "id", "type": "uint256" },
      { "internalType": "string", "name": "rfidOut", "type": "string" },
      { "internalType": "string", "name": "name", "type": "string" },
      { "internalType": "uint8", "name": "assetType", "type": "uint8" },
      { "internalType": "uint8", "name": "location", "type": "uint8" },
      { "internalType": "uint8", "name": "availability", "type": "uint8" },
      { "internalType": "address", "name": "createdBy", "type": "address" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "string", "name": "rfid", "type": "string" }
    ],
    "name": "getAssetStatusByRFID",
    "outputs": [
      { "internalType": "string", "name": "rfidOut", "type": "string" },
      { "internalType": "string", "name": "name", "type": "string" },
      { "internalType": "uint8", "name": "location", "type": "uint8" },
      { "internalType": "uint8", "name": "availability", "type": "uint8" }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]

# -------------------------
# SIMPLE RFID INPUT (keyboard wedge)
# -------------------------
def read_rfid():
    return input("Scan RFID: ").strip()

# -------------------------
# MAIN
# -------------------------
def main():
    w3 = Web3(Web3.HTTPProvider(RPC_URL))
    print("Connected to Sepolia:", w3.is_connected())

    contract = w3.eth.contract(
        address=Web3.to_checksum_address(CONTRACT_ADDRESS),
        abi=CONTRACT_ABI
    )

    print("Ready. Scan an RFID tag... (Ctrl+C to exit)")

    location_map = {
        0: "AtManufacturer",
        1: "AtLogisticsCompany",
        2: "InShipment"
    }

    availability_map = {
        0: "InUse",
        1: "InStorage",
        2: "Damaged",
        3: "Sold"
    }

    while True:
        rfid = read_rfid()
        print("\nScanned RFID:", rfid)

        try:
            rfidOut, name, location, availability = contract.functions.getAssetStatusByRFID(rfid).call()

            print("On-chain data:")
            print("  RFID:        ", rfidOut)
            print("  Name:        ", name)
            print("  Location ID: ", location)
            print("  Status ID:   ", availability)
            print("  Location:    ", location_map.get(location, f"Unknown({location})"))
            print("  Availability:", availability_map.get(availability, f"Unknown({availability})"))

        except Exception as e:
            print("RFID not found on-chain or error occurred:")
            print("  ", e)

if __name__ == "__main__":
    main()
