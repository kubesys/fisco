pragma solidity>=0.4.24 <0.6.11;

contract AssetLeasing {

    struct Asset {
        address owner;
        string assetID;
        bool isLeased;
        uint pricePerHour;
        address renter;
        uint rentedTime;
    }

    struct Debt {
        string assetID;
        uint pricePerHour;
        uint leaseHours;
        uint amount;
        address creditor;
    }

    mapping(string => Asset) private assets;
    mapping(address => Debt[]) private debts;
    string[] private assetIds;
    
    event AssetRegistered(string assetID);
    event AssetLeased(string assetID);
    event AssetReturned(string assetID);

    function registerAsset(string memory _assetID, uint _pricePerHour) public {
        require(bytes(assets[_assetID].assetID).length == 0, "Asset already registered");

        Asset memory newAsset = Asset({
            owner: msg.sender,
            assetID: _assetID,
            isLeased: false,
            pricePerHour: _pricePerHour,
            renter: address(0),
            rentedTime: 0
        });

        assets[_assetID] = newAsset;
        assetIds.push(_assetID);
        
        emit AssetRegistered(_assetID);
    }

    function leaseAsset(string memory _assetID) public {
        require(bytes(assets[_assetID].assetID).length != 0, "Asset not registered");
        require(assets[_assetID].isLeased == false, "Asset already leased");
        require(assets[_assetID].owner != msg.sender, "Cannot lease your own asset");

        assets[_assetID].isLeased = true;
        assets[_assetID].renter = msg.sender;
        assets[_assetID].rentedTime = now;

        emit AssetLeased(_assetID);
    }

    function returnAsset(string memory _assetID) public {
        require(assets[_assetID].isLeased == true, "Asset is not leased");
        require(assets[_assetID].renter == msg.sender, "You are not the renter of this asset");

        uint rentTimeInMinutes = (now - assets[_assetID].rentedTime) / 1000;
        uint actualHours = rentTimeInMinutes / 1 hours;
        if (rentTimeInMinutes % 60 minutes > 0) {
            actualHours++;
        }
        uint actualRent = actualHours * assets[_assetID].pricePerHour;


        debts[msg.sender].push(Debt({
            assetID:_assetID,
            pricePerHour:assets[_assetID].pricePerHour,
            leaseHours:actualHours,
            amount: actualRent,
            creditor: assets[_assetID].owner
        }));

        assets[_assetID].isLeased = false;
        assets[_assetID].renter = address(0);
        assets[_assetID].rentedTime = 0;

        emit AssetReturned(_assetID);
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

    function getAvailableAssetsLength() public view returns (uint) {
        uint count;
        for (uint i = 0; i < assetIds.length; i++) {
            if (!assets[assetIds[i]].isLeased) {
                count++;
            }
        }
    	return count;
    }

    function getAvailableAssets_owner(uint count) public view returns (address[] memory) {
        address[] memory AvailableAssets_owner = new address[](count);
        uint index = 0;
        for (uint i = 0;i < assetIds.length; i++) {
            if (!assets[assetIds[i]].isLeased) {
            	AvailableAssets_owner[index] = assets[assetIds[i]].owner;
            	index++;
            }    
        }
        return AvailableAssets_owner;
    }

    function getAvailableAssets_assetID(uint count) public view returns (bytes32[] memory) {
        bytes32[] memory availableAssets = new bytes32[](count);
        uint index = 0;
        for (uint j = 0; j < assetIds.length; j++) {
            if (!assets[assetIds[j]].isLeased) {
                availableAssets[index] = stringToBytes32(assetIds[j]);
                index++;
            }
        }
        
        return availableAssets;
    }
    
    function getAvailableAssets_pricePerHour(uint count) public view returns (uint[] memory) {
        uint[] memory AvailableAssets_pricePerHour = new uint[](count);
        uint index = 0;
        for (uint i = 0;i < assetIds.length; i++) {
            if (!assets[assetIds[i]].isLeased) {
                AvailableAssets_pricePerHour[index] = assets[assetIds[i]].pricePerHour;
                index++;
            }
        }
        return AvailableAssets_pricePerHour;
    }
    
    function getLeasedAssetsLength() public view returns (uint) {
        uint count;
        for (uint i = 0; i < assetIds.length; i++) {
            if (assets[assetIds[i]].isLeased) {
                count++;
            }
        }
    	return count;
    }
    
    function getLeasedAssets_owner(uint count) public view returns (address[] memory) {
        address[] memory LeasedAssets_owner = new address[](count);
        uint index = 0;
        for (uint i = 0;i < assetIds.length; i++) {
            if (assets[assetIds[i]].isLeased) {
                LeasedAssets_owner[index] = assets[assetIds[i]].owner;
                index++;
            }

        }
        return LeasedAssets_owner;
    }
    
    function getLeasedAssets_assetID(uint count) public view returns (bytes32[] memory) {
        bytes32[] memory leasedAssets = new bytes32[](count);
        uint index = 0;
        for (uint j = 0; j < assetIds.length; j++) {
            if (assets[assetIds[j]].isLeased) {
                leasedAssets[index] = stringToBytes32(assetIds[j]);
                index++;
            }
        }
    
        return leasedAssets;
    }
    
    function getLeasedAssets_pricePerHour(uint count) public view returns (uint[] memory) {
        uint[] memory LeasedAssets_pricePerHour = new uint[](count);
        uint index = 0;
        for (uint i = 0;i < assetIds.length; i++) {
            if (assets[assetIds[i]].isLeased) {
                LeasedAssets_pricePerHour[index] = assets[assetIds[i]].pricePerHour;
                index++;
            }

        }
        return LeasedAssets_pricePerHour;
    }
    
    function getLeasedAssets_renter(uint count) public view returns (address[] memory) {
        address[] memory LeasedAssets_renter = new address [](count);
        uint index = 0;
        for (uint i = 0;i < assetIds.length; i++) {
            if (assets[assetIds[i]].isLeased) {
                LeasedAssets_renter[index] = assets[assetIds[i]].renter;
                index++;
            }

        }
        return LeasedAssets_renter;
    }
    
    function getLeasedAssets_rentedTime(uint count) public view returns (uint[] memory) {
        uint[] memory LeasedAssets_rentedTime = new uint[](count);
        uint index = 0;
        for (uint i = 0;i < assetIds.length; i++) {
            if (assets[assetIds[i]].isLeased) {
                LeasedAssets_rentedTime[index] = assets[assetIds[i]].rentedTime;
                index++;
            }

        }
        return LeasedAssets_rentedTime;
    }
    
    function getdebtlength(address debtor) public view returns (uint) {
    	return debts[debtor].length;
    }
    
    function getDebt_assetID(address debtor,uint index) public view returns (bytes32[] memory) {
        bytes32[] memory userDebts_assetID = new bytes32[](10);
        for (uint i = 0; i < 10; i++) {
            if (index < debts[debtor].length)
            	userDebts_assetID[i] = stringToBytes32(debts[debtor][index].assetID);
            else
            	userDebts_assetID[i] = stringToBytes32("");
            index++;
        }
    
        return userDebts_assetID;
    }

    function getDebt_pricePerHour(address debtor,uint index) public view returns (uint[10] memory) {
        uint[10] memory userDebts_pricePerHour;
        for (uint i = 0;i < 10; i++) {
            if (index < debts[debtor].length)
            	userDebts_pricePerHour[i] = debts[debtor][index].pricePerHour;
            else

            	userDebts_pricePerHour[i] = 0;
            index++;
        }
        return userDebts_pricePerHour;
    }
    
    function getDebt_leaseHours(address debtor,uint index) public view returns (uint[10] memory) {
        uint[10] memory userDebts_leaseHours;
        for (uint i = 0;i < 10; i++) {
            if (index < debts[debtor].length)
            	userDebts_leaseHours[i] = debts[debtor][index].leaseHours;
            else
            	userDebts_leaseHours[i] = 0;
            index++;
        }
        return userDebts_leaseHours;
    }
    
    function getDebt_amount(address debtor,uint index) public view returns (uint[10] memory) {
        uint[10] memory userDebts_amount;
        for (uint i = 0;i < 10; i++) {
            if (index < debts[debtor].length)
            	userDebts_amount[i] = debts[debtor][index].amount;
            else
            	userDebts_amount[i] = 0;
            index++;
        }
        return userDebts_amount;
    }
    
    function getDebt_creditor(address debtor,uint index) public view returns (address[10] memory) {
        address[10] memory userDebts_creditor;
        for (uint i = 0;i < 10; i++) {
            if (index < debts[debtor].length)
            	userDebts_creditor[i] = debts[debtor][index].creditor;
            else
            	userDebts_creditor[i] = address(0);
            index++;
        }
        return userDebts_creditor;
    }
    
    function settle(address goal, uint index) public {
        require(index < debts[goal].length, "Invalid debt index");

        removeDebt(goal, index);
    }


    function removeDebt(address debtor, uint index) private {
        Debt[] storage userDebts = debts[debtor];
        userDebts[index] = userDebts[userDebts.length - 1];
        userDebts[userDebts.length - 1] = Debt({assetID: "0", pricePerHour:0, leaseHours:0, amount: 0, creditor: address(0)});
	userDebts.length--;
    }
    

}