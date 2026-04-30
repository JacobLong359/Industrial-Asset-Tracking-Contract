// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IndustrialAssetTracking {

    enum Role {
        None,
        MainOperator,
        FactoryWorker,
        LogisticsWorker,
        SupplierWorker,
        Regulator
    }

    enum AssetType {
        Product,
        ManufacturingEquipment,
        ShippingContainer,
        MaterialComponent,
        Tooling,
        Vehicle
    }

    enum LocationStatus {
        AtManufacturer,
        AtLogisticsCompany,
        InShipment
    }

    enum AvailabilityStatus {
        InUse,
        InStorage,
        Damaged,
        Sold
    }

    struct Asset {
        uint256 id;
        string rfid;
        string name;
        AssetType assetType;
        LocationStatus location;
        AvailabilityStatus availability;
        address createdBy;
        bool exists;
    }

    mapping(address => Role) public userRoles;
    mapping(uint256 => Asset) public assets;

    // FIXED: 0 = unused, stored value = assetId + 1
    mapping(string => uint256) public rfidToAssetId;

    uint256 public nextAssetId;
    address public owner;

    event UserRoleAssigned(address indexed user, Role role);
    event UserRoleRemoved(address indexed user);

    event AssetCreated(
        uint256 indexed assetId,
        string rfid,
        string name,
        AssetType assetType,
        LocationStatus location,
        AvailabilityStatus availability,
        address indexed createdBy
    );

    event AssetDeleted(uint256 indexed assetId, address indexed deletedBy);

    event AssetLocationUpdated(
        uint256 indexed assetId,
        LocationStatus oldLocation,
        LocationStatus newLocation,
        address indexed updatedBy
    );

    event AssetAvailabilityUpdated(
        uint256 indexed assetId,
        AvailabilityStatus oldAvailability,
        AvailabilityStatus newAvailability,
        address indexed updatedBy
    );

    modifier onlyMainOperator() {
        require(
            userRoles[msg.sender] == Role.MainOperator || msg.sender == owner,
            "Only main operator"
        );
        _;
    }

    modifier onlyRole(Role r) {
        require(userRoles[msg.sender] == r, "Not authorized");
        _;
    }

    modifier assetExists(uint256 assetId) {
        require(assets[assetId].exists, "Asset does not exist");
        _;
    }

    // FIXED: RFID existence check now works for assetId = 0
    modifier rfidExists(string memory rfid) {
        uint256 stored = rfidToAssetId[rfid];
        require(stored != 0, "RFID not found");
        require(assets[stored - 1].exists, "RFID not found");
        _;
    }

    constructor() {
        owner = msg.sender;
        userRoles[msg.sender] = Role.MainOperator;
        emit UserRoleAssigned(msg.sender, Role.MainOperator);
    }

    function _roleFromString(string memory role) internal pure returns (Role) {
        bytes32 r = keccak256(abi.encodePacked(role));

        if (r == keccak256("MainOperator")) return Role.MainOperator;
        if (r == keccak256("FactoryWorker")) return Role.FactoryWorker;
        if (r == keccak256("LogisticsWorker")) return Role.LogisticsWorker;
        if (r == keccak256("SupplierWorker")) return Role.SupplierWorker;
        if (r == keccak256("Regulator")) return Role.Regulator;

        revert("Invalid role");
    }

    function _assetTypeFromString(string memory t) internal pure returns (AssetType) {
        bytes32 a = keccak256(abi.encodePacked(t));

        if (a == keccak256("Product")) return AssetType.Product;
        if (a == keccak256("ManufacturingEquipment")) return AssetType.ManufacturingEquipment;
        if (a == keccak256("ShippingContainer")) return AssetType.ShippingContainer;
        if (a == keccak256("MaterialComponent")) return AssetType.MaterialComponent;
        if (a == keccak256("Tooling")) return AssetType.Tooling;
        if (a == keccak256("Vehicle")) return AssetType.Vehicle;

        revert("Invalid asset type");
    }

    function _locationFromString(string memory loc) internal pure returns (LocationStatus) {
        bytes32 l = keccak256(abi.encodePacked(loc));

        if (l == keccak256("AtManufacturer")) return LocationStatus.AtManufacturer;
        if (l == keccak256("AtLogisticsCompany")) return LocationStatus.AtLogisticsCompany;
        if (l == keccak256("InShipment")) return LocationStatus.InShipment;

        revert("Invalid location");
    }

    function _availabilityFromString(string memory avail) internal pure returns (AvailabilityStatus) {
        bytes32 v = keccak256(abi.encodePacked(avail));

        if (v == keccak256("InUse")) return AvailabilityStatus.InUse;
        if (v == keccak256("InStorage")) return AvailabilityStatus.InStorage;
        if (v == keccak256("Damaged")) return AvailabilityStatus.Damaged;
        if (v == keccak256("Sold")) return AvailabilityStatus.Sold;

        revert("Invalid availability");
    }

    function setUserRole(address user, string memory roleName)
        external
        onlyMainOperator
    {
        Role r = _roleFromString(roleName);
        userRoles[user] = r;
        emit UserRoleAssigned(user, r);
    }

    function removeUser(address user) external onlyMainOperator {
        delete userRoles[user];
        emit UserRoleRemoved(user);
    }

    // FIXED: RFID uniqueness check now correct
    function _createAsset(
        string memory rfid,
        string memory name,
        AssetType assetType,
        LocationStatus location,
        AvailabilityStatus availability
    ) internal returns (uint256) {

        require(rfidToAssetId[rfid] == 0, "RFID already exists");

        uint256 assetId = nextAssetId++;

        assets[assetId] = Asset({
            id: assetId,
            rfid: rfid,
            name: name,
            assetType: assetType,
            location: location,
            availability: availability,
            createdBy: msg.sender,
            exists: true
        });

        // FIXED: store assetId + 1
        rfidToAssetId[rfid] = assetId + 1;

        emit AssetCreated(assetId, rfid, name, assetType, location, availability, msg.sender);
        return assetId;
    }

    function _deleteAsset(uint256 assetId) internal {
        string memory rfid = assets[assetId].rfid;
        delete rfidToAssetId[rfid];
        delete assets[assetId];
        emit AssetDeleted(assetId, msg.sender);
    }

    function createManufacturingAsset(
        string memory rfid,
        string memory name,
        string memory assetTypeName,
        string memory locationName,
        string memory availabilityName
    ) external onlyRole(Role.FactoryWorker) returns (uint256) {

        AssetType t = _assetTypeFromString(assetTypeName);
        require(
            t == AssetType.Product ||
            t == AssetType.ManufacturingEquipment ||
            t == AssetType.Tooling ||
            t == AssetType.MaterialComponent,
            "Invalid manufacturing asset"
        );

        return _createAsset(
            rfid,
            name,
            t,
            _locationFromString(locationName),
            _availabilityFromString(availabilityName)
        );
    }

    function createLogisticsAsset(
        string memory rfid,
        string memory name,
        string memory assetTypeName,
        string memory locationName,
        string memory availabilityName
    ) external onlyRole(Role.LogisticsWorker) returns (uint256) {

        AssetType t = _assetTypeFromString(assetTypeName);
        require(
            t == AssetType.ShippingContainer ||
            t == AssetType.Vehicle,
            "Invalid logistics asset"
        );

        return _createAsset(
            rfid,
            name,
            t,
            _locationFromString(locationName),
            _availabilityFromString(availabilityName)
        );
    }

    function createSupplierAsset(
        string memory rfid,
        string memory name,
        string memory assetTypeName,
        string memory locationName,
        string memory availabilityName
    ) external onlyRole(Role.SupplierWorker) returns (uint256) {

        AssetType t = _assetTypeFromString(assetTypeName);
        require(
            t == AssetType.MaterialComponent ||
            t == AssetType.Product ||
            t == AssetType.Tooling,
            "Invalid supplier asset"
        );

        return _createAsset(
            rfid,
            name,
            t,
            _locationFromString(locationName),
            _availabilityFromString(availabilityName)
        );
    }

    function updateAssetAvailability(uint256 assetId, string memory newAvailability)
        external
        assetExists(assetId)
    {
        Role r = userRoles[msg.sender];
        require(
            r == Role.MainOperator ||
            r == Role.FactoryWorker ||
            r == Role.LogisticsWorker ||
            r == Role.SupplierWorker,
            "Not allowed"
        );

        Asset storage a = assets[assetId];
        AvailabilityStatus oldAvail = a.availability;
        a.availability = _availabilityFromString(newAvailability);

        emit AssetAvailabilityUpdated(assetId, oldAvail, a.availability, msg.sender);
    }

    function getAssetByRFID(string memory rfid)
        external
        view
        rfidExists(rfid)
        returns (
            uint256 id,
            string memory rfidOut,
            string memory name,
            AssetType assetType,
            LocationStatus location,
            AvailabilityStatus availability,
            address createdBy
        )
    {
        uint256 stored = rfidToAssetId[rfid];
        uint256 assetId = stored - 1;
        Asset storage a = assets[assetId];
        return (a.id, a.rfid, a.name, a.assetType, a.location, a.availability, a.createdBy);
    }

    function getAssetStatusByRFID(string memory rfid)
        external
        view
        rfidExists(rfid)
        returns (
            string memory rfidOut,
            string memory name,
            LocationStatus location,
            AvailabilityStatus availability
        )
    {
        uint256 stored = rfidToAssetId[rfid];
        uint256 assetId = stored - 1;
        Asset storage a = assets[assetId];
        return (a.rfid, a.name, a.location, a.availability);
    }
}