Project by: JEL359
Date: May 2026

Industrial Asset Tracking Smart Contract - README.txt

TITLE: Industrial Asset Tracking Smart Contract

OVERVIEW: This Solidity smart contract provides an on‑chain registry for industrial assets identified by RFID tags. Each asset is stored with key metadata such as name, RFID, manufacturing date, warranty expiration, operational status, and current location. The contract allows adding new assets, updating asset information, and retrieving asset details by RFID.

FEATURES:
- Register New Assets
- Creates a new asset entry with all required metadata.
- Each RFID can only be registered once.
- Update Asset Status
- Allows modifying the operational status of an asset (for example: Active, In Repair, Retired).
- Update Asset Location
- Tracks where the asset is currently deployed or stored.
- Lookup by RFID
- Retrieves all stored metadata for any registered asset.
- Event Logging
- Emits events when assets are created or updated so off‑chain systems can listen and react.

DATA MODEL: Each asset is stored as a struct:
Asset { string name; string rfid; string status; string location; uint256 manufacturedOn; uint256 warrantyUntil; }

Assets are stored in a mapping: mapping(string => Asset) private assets;

ACCESS CONTROL: Only authorized users are allowed to register or modify assets. This prevents unauthorized updates to asset records.

USE CASES:
- Manufacturing supply chains
- Industrial equipment tracking
- Warranty lifecycle management
- Asset auditing and compliance
- IoT and RFID integrations with blockchain

TESTING: The contract can be tested using:
- Remix IDE (recommended)

Note: This project includes code generated with the assistance of Microsoft Copilot and Remix IDE AI.
