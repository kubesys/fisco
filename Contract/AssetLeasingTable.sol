pragma solidity>=0.4.24 <0.6.11;

import "./Table.sol";

contract AssetLeasingTable {

    TableFactory tableFactory;
    string constant ASSET_TABLE_NAME = "t_assets";
    string constant DEBT_TABLE_NAME = "t_debts";

    constructor() public {
        tableFactory = TableFactory(0x1001);
        
        tableFactory.createTable(ASSET_TABLE_NAME, "id", "owner,assetID,isLeased,pricePerHour,renter,rentedTime");
        tableFactory.createTable(DEBT_TABLE_NAME, "id", "debtor,assetID,pricePerHour,leaseHours,amount,creditor");
    }

    function stringequal(string memory s1, string memory s2) public pure returns(bool) {
        if (keccak256(abi.encodePacked((s1))) == keccak256(abi.encodePacked((s2)))) {
            return true;
        } else {
            return false;
        }
    }


    function registerAsset(string _owner, string memory _assetID, int256 _pricePerHour) public returns (int256) {
    	Table table = tableFactory.openTable(ASSET_TABLE_NAME);
    	
    	Condition condition = table.newCondition();
        condition.EQ("assetID", _assetID);
        
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        require(entries.size() == 0, "Asset already registered");

	Entry entry = table.newEntry();
	entry.set("owner", _owner);
        entry.set("assetID", _assetID);
        entry.set("isLeased", "false");
        entry.set("pricePerHour", _pricePerHour);
        entry.set("renter", "");
        entry.set("rentedTime", uint256(0));
        
        int256 count = table.insert(ASSET_TABLE_NAME, entry);
        return count;
    }

    function leaseAsset(string _renter, string memory _assetID) public returns (int256) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("assetID", _assetID);
        
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        require(entries.size() != 0, "Asset not registered");

        Entry entry = entries.get(0);
        require(stringequal(entry.getString("isLeased"), "false"), "Asset already leased");
        require(!stringequal(entry.getString("owner"), _renter), "Cannot lease your own asset");
        
        entry.set("isLeased", "true");
        entry.set("renter", _renter);
        entry.set("rentedTime", now);
        
        int256 count = table.update(ASSET_TABLE_NAME, entry, condition);
        return count;
    }

    function returnAsset(string _name, string memory _assetID) public {
        Table asset_table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = asset_table.newCondition();
        condition.EQ("assetID", _assetID);
        
        Entries entries = asset_table.select(ASSET_TABLE_NAME, condition);
        require(entries.size() != 0, "Asset not registered");
        
        
        Entry entry = entries.get(0);
        require(stringequal(entry.getString("isLeased"), "true"), "Asset is not leased");
        require(stringequal(entry.getString("renter"), _name), "You are not the renter of this asset");

        uint256 rentTimeInMinutes = (now - entry.getUInt("rentedTime")) / 1000;
        uint256 actualHours = rentTimeInMinutes / 1 hours;
        if (rentTimeInMinutes % 60 minutes > 0) {
            actualHours++;
        }
        uint256 actualRent = actualHours * entry.getUInt("pricePerHour");


        Table debt_table = tableFactory.openTable(DEBT_TABLE_NAME);

        Entry debt_entry = debt_table.newEntry();
        debt_entry.set("debtor", _name);
        debt_entry.set("assetID", _assetID);
        debt_entry.set("pricePerHour", entry.getUInt("pricePerHour"));
        debt_entry.set("leaseHours", actualHours);
        debt_entry.set("amount", actualRent);
        debt_entry.set("creditor", entry.getString("owner"));
        int256 debt_count = debt_table.insert(DEBT_TABLE_NAME, debt_entry);


        entry.set("isLeased", "false");
        entry.set("renter", "");
        entry.set("rentedTime", uint256(0));
        
        int256 count = asset_table.update(ASSET_TABLE_NAME, entry, condition);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }


    function getAvailableAssets_owner() public view returns (bytes32[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "false");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        
        bytes32[] memory AvailableAssets_owner = new bytes32[](uint256(entries.size()));

        for (int256 i = 0;i < entries.size(); i++) {
            AvailableAssets_owner[uint256(i)] =  stringToBytes32(entries.get(i).getString("owner"));
        }
        return AvailableAssets_owner;
    }

    function getAvailableAssets_assetID() public view returns (bytes32[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "false");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        
        bytes32[] memory availableAssets = new bytes32[](uint256(entries.size()));

        for (int256 i = 0; i < entries.size(); i++) {
            availableAssets[uint256(i)] =  stringToBytes32(entries.get(i).getString("assetID"));
        }
        return availableAssets;
    }
    
    function getAvailableAssets_pricePerHour() public view returns (uint[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "false");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        
        uint[] memory AvailableAssets_pricePerHour = new uint[](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            AvailableAssets_pricePerHour[uint256(i)] = entries.get(i).getUInt("pricePerHour");
        }
        return AvailableAssets_pricePerHour;
    }
    
    function getLeasedAssets_owner() public view returns (bytes32[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "true");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        
        bytes32[] memory LeasedAssets_owner = new bytes32[](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            LeasedAssets_owner[uint256(i)] = stringToBytes32(entries.get(i).getString("owner"));
        }
        return LeasedAssets_owner;
    }
    
    function getLeasedAssets_assetID() public view returns (bytes32[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "true");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        
        bytes32[] memory leasedAssets = new bytes32[](uint256(entries.size()));
        for (int256 i = 0; i < entries.size(); i++) {
            leasedAssets[uint256(i)] = stringToBytes32(entries.get(i).getString("assetID"));
        }
    
        return leasedAssets;
    }
    
    function getLeasedAssets_pricePerHour() public view returns (uint[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "true");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        
        uint[] memory LeasedAssets_pricePerHour = new uint[](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            LeasedAssets_pricePerHour[uint256(i)] = entries.get(i).getUInt("pricePerHour");
        }
        return LeasedAssets_pricePerHour;
    }
    
    function getLeasedAssets_renter() public view returns (bytes32[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "true");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
        
        bytes32[] memory LeasedAssets_renter = new bytes32 [](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            LeasedAssets_renter[uint256(i)] = stringToBytes32(entries.get(i).getString("renter"));
        }
        return LeasedAssets_renter;
    }
    
    function getLeasedAssets_rentedTime() public view returns (uint[] memory) {
        Table table = tableFactory.openTable(ASSET_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("isLeased", "true");
        Entries entries = table.select(ASSET_TABLE_NAME, condition);
      
        uint[] memory LeasedAssets_rentedTime = new uint[](uint256(entries.size()));
        
        for (int256 i = 0;i < entries.size(); i++) {
            LeasedAssets_rentedTime[uint256(i)] = entries.get(i).getUInt("rentedTime");
        }
        return LeasedAssets_rentedTime;
    }
    
    
    function getDebt_assetID(string debtor) public view returns (bytes32[] memory) {
        Table table = tableFactory.openTable(DEBT_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("debtor", debtor);
        Entries entries = table.select(DEBT_TABLE_NAME, condition);
        
        bytes32[] memory userDebts_assetID = new bytes32[](uint256(entries.size()));
        for (int256 i = 0; i < entries.size(); i++) {
            userDebts_assetID[uint256(i)] = stringToBytes32(entries.get(i).getString("assetID"));
        }
        return userDebts_assetID;
    }

    function getDebt_pricePerHour(string debtor) public view returns (uint[] memory) {
        Table table = tableFactory.openTable(DEBT_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("debtor", debtor);
        Entries entries = table.select(DEBT_TABLE_NAME, condition);
    
        uint[] memory userDebts_pricePerHour = new uint[](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            userDebts_pricePerHour[uint256(i)] = entries.get(i).getUInt("pricePerHour");
        }
        return userDebts_pricePerHour;
    }
    
    function getDebt_leaseHours(string debtor) public view returns (uint[] memory) {
        Table table = tableFactory.openTable(DEBT_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("debtor", debtor);
        Entries entries = table.select(DEBT_TABLE_NAME, condition);
    
        uint[] memory userDebts_leaseHours = new uint[](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            userDebts_leaseHours[uint256(i)] = entries.get(i).getUInt("leaseHours");
        }
        return userDebts_leaseHours;
    }
    
    function getDebt_amount(string debtor) public view returns (uint[] memory) {
        Table table = tableFactory.openTable(DEBT_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("debtor", debtor);
        Entries entries = table.select(DEBT_TABLE_NAME, condition);
    
        uint[] memory userDebts_amount = new uint[](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            userDebts_amount[uint256(i)] = entries.get(i).getUInt("amount");
        }
        return userDebts_amount;
    }
    
    function getDebt_creditor(string debtor) public view returns (bytes32[] memory) {
        Table table = tableFactory.openTable(DEBT_TABLE_NAME);
        
        Condition condition = table.newCondition();
        condition.EQ("debtor", debtor);
        Entries entries = table.select(DEBT_TABLE_NAME, condition);
    
        bytes32[] memory userDebts_creditor = new bytes32[](uint256(entries.size()));
        for (int256 i = 0;i < entries.size(); i++) {
            userDebts_creditor[uint256(i)] = stringToBytes32(entries.get(i).getString("creditor"));
        }
        return userDebts_creditor;
    }
}
