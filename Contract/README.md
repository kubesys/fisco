# Contract

资产租赁智能合约相关代码

## AssetLeasing.sol

资产租赁智能合约。

### 数据结构

- Asset结构体（资产）
  - address owner;//资产拥有方
  - string assetID;//资产ID
  - bool isLeased;//资产是否被租赁
  - uint pricePerHour;//资产每小时租赁价
  - address renter;//资产租赁方
  - uint rentedTime;//租赁起始时间
- Debt结构体（账单）
  - string assetID;//资产ID
  - uint pricePerHour;//资产每小时租赁价
  - uint leaseHours;//租赁总时长，向上取整，未满一小时取一小时
  - uint amount;//租赁总额
  - address creditor;//债主，即该资产的拥有方
- mapping(string => Asset) private assets;//资产哈希表，每个String（资产名）对应一个Asset结构体
- mapping(address => Debt[]) private debts;//账单哈希表，每个address（用户）对应一个Debt账单数组

### 方法函数

- function registerAsset(string memory _assetID, uint _pricePerHour)
  - 函数功能：注册新资产，资产拥有方为该函数的调用者
  - 输入参数：资产ID、资产每小时租赁价
  - 返回值：无
- function leaseAsset(string memory _assetID)
  - 函数功能：租赁资产，资产租赁房为该函数的调用者
  - 输入参数：资产ID
  - 返回值：无
- function returnAsset(string memory _assetID)
  - 函数功能：归还资产
  - 输入参数：资产ID
  - 返回值：无
- function getAvailableAssetsLength() public view returns (uint)
  - 函数功能：获取可租赁的资产数量
  - 输入参数：无
  - 返回值：可租赁的资产数量
- function getAvailableAssets_owner(uint count) public view returns (address[] memory)
  - 函数功能：获取可租赁的资产对应的拥有人
  - 输入参数：可租赁的资产数量
  - 返回值：每个可租赁的资产所对应的拥有人组成的数组
- function getAvailableAssets_assetID(uint count) public view returns (bytes32[] memory)
  - 函数功能：获取可租赁的资产对应的资产ID
  - 输入参数：可租赁的资产数量
  - 返回值：每个可租赁的资产所对应的资产ID组成的数组
- function getAvailableAssets_pricePerHour(uint count) public view returns (uint[] memory)
  - 函数功能：获取可租赁的资产对应的每小时价格
  - 输入参数：可租赁的资产数量
  - 返回值：每个可租赁的资产所对应的每小时价格组成的数组
- function getLeasedAssetsLength() public view returns (uint)
  - 函数功能：获取已被租赁的资产数量
  - 输入参数：无
  - 返回值：已被租赁的资产数量
- function getLeasedAssets_owner(uint count) public view returns (address[] memory)
  - 函数功能：获取已被租赁的资产对应的资产拥有方
  - 输入参数：已被租赁的资产数量
  - 返回值：每个已被租赁的资产所对应的资产拥有方组成的数组
- function getLeasedAssets_assetID(uint count) public view returns (bytes32[] memory)
  - 函数功能：获取已被租赁的资产对应的资产ID
  - 输入参数：已被租赁的资产数量
  - 返回值：每个已被租赁的资产所对应的资产ID组成的数组
- function getLeasedAssets_pricePerHour(uint count) public view returns (uint[] memory)
  - 函数功能：获取已被租赁的资产对应的每小时价格
  - 输入参数：已被租赁的资产数量
  - 返回值：每个已被租赁的资产所对应的每小时价格组成的数组
- function getLeasedAssets_renter(uint count) public view returns (address[] memory)
  - 函数功能：获取已被租赁的资产对应的租赁方
  - 输入参数：已被租赁的资产数量
  - 返回值：每个已被租赁的资产所对应的租赁方组成的数组
- function getLeasedAssets_rentedTime(uint count) public view returns (uint[] memory)
  - 函数功能：获取已被租赁的资产对应的租赁起始时间
  - 输入参数：已被租赁的资产数量
  - 返回值：每个已被租赁的资产所对应的租赁起始时间组成的数组
- function getdebtlength(address debtor) public view returns (uint)
  - 函数功能：获取某位用户的账单数
  - 输入参数：用户对应的address
  - 返回值：该用户的账单数
- function getDebt_assetID(address debtor,uint index) public view returns (bytes32[] memory)
  - 函数功能：获取某位用户的账单对应的资产ID
  - 输入参数：用户对应的address，账单的index
  - 返回值：该用户账单对应的资产ID
- function getDebt_pricePerHour(address debtor,uint index) public view returns (uint[10] memory)
  - 函数功能：获取某位用户的账单对应的资产每小时价格
  - 输入参数：用户对应的address，账单的index
  - 返回值：该用户账单对应的资产每小时价格
- function getDebt_leaseHours(address debtor,uint index) public view returns (uint[10] memory)
  - 函数功能：获取某位用户的账单对应的资产租赁时间
  - 输入参数：用户对应的address，账单的index
  - 返回值：该用户账单对应的资产租赁时间
- function getDebt_amount(address debtor,uint index) public view returns (uint[10] memory)
  - 函数功能：获取某位用户的账单对应的价格总额
  - 输入参数：用户对应的address，账单的index
  - 返回值：该用户账单对应的价格总额
- function getDebt_creditor(address debtor,uint index) public view returns (address[10] memory)
  - 函数功能：获取某位用户的账单对应的债权方
  - 输入参数：用户对应的address，账单的index
  - 返回值：该用户账单对应的债权方
- function removeDebt(address debtor, uint index)
  - 函数功能：删除某位用户的账单
  - 输入参数：用户对应的address，账单的index
  - 返回值：无

## Table.sol

Table.sol合约是一个抽象接口合约文件。Table.sol包含分布式存储专用的智能合约接口，其接口实现在区块链节点中可以创建表，并对表进行增删改查的操作。

Table.sol抽象接口合约文件包括以下抽象合约接口，下面分别进行介绍。

### TableFactory合约

用于创建和打开表，其固定合约地址为0x1001，接口如下：

| 接口                                | 功能   | 参数                                                         | 返回值                                        |
| ----------------------------------- | ------ | ------------------------------------------------------------ | --------------------------------------------- |
| createTable(string ,string, string) | 创建表 | 表名，主键名（目前只支持单个主键），表的其他字段名（字段之间以英文逗号分隔） | 返回错误码（int256），错误码详见下表          |
| opentTable(string)                  | 打开表 | 表名                                                         | 返回合约Table的地址，当表名不存在时返回空地址 |

**createTable接口返回：**

| 错误码 | 说明                         |
| :----- | :--------------------------- |
| 0      | 创建成功                     |
| -50000 | 用户没有权限                 |
| -50001 | 创建表名已存在               |
| -50002 | 表名超过48字符               |
| -50003 | valueField长度超过64字符     |
| -50004 | valueField总长度超过1024字符 |
| -50005 | keyField长度超过64字符       |
| -50007 | 存在重复字段                 |
| -50007 | 字段存在非法字符             |
| 其他   | 创建时遇到的其他错误         |

### Entry合约

Entry代表记录对象，一个Entry对象代表一行记录，其接口如下：

| 接口                 | 功能       | 参数           | 返回值 |
| -------------------- | ---------- | -------------- | ------ |
| set(string, int)     | 设置字段   | 字段名，字段值 | void   |
| set(string, string)  | 设置字段   | 字段名，字段值 | void   |
| set(string, address) | 设置字段   | 字段名，字段值 | void   |
| getInt(string)       | 获取字段值 | 字段名         | void   |
| getString(string)    | 获取字段值 | 字段名         | void   |
| getBytes64(string)   | 获取字段值 | 字段名         | void   |
| getBytes32(string)   | 获取字段值 | 字段名         | void   |
| getAddress(string)   | 获取字段值 | 字段名         | void   |

### Entries合约

Entries是记录集合对象，Entries用于存放Entry对象，其接口如下：

| 接口     | 功能                | 参数          | 返回值                |
| -------- | ------------------- | ------------- | --------------------- |
| get(int) | 获取指定索引的Entry | Entries的索引 | 合约Entry的地址       |
| size()   | 获取Entries的大小   | 无            | Entries的大小(int256) |

### Condition合约

查询、更新和删除记录时指定的过滤条件对象，其接口如下：

| 接口               | 功能           | 参数                           | 返回值 |
| ------------------ | -------------- | ------------------------------ | ------ |
| EQ(string, int)    | 相等条件       | 字段名，字段值                 | void   |
| EQ(string, string) | 相等条件       | 字段名，字段值                 | void   |
| NE(string, int)    | 不等条件       | 字段名，字段值                 | void   |
| NE(string, string) | 不等条件       | 字段名，字段值                 | void   |
| GT(string, int)    | 大于条件       | 字段名，字段值                 | void   |
| GE(string, int)    | 大于或等于条件 | 字段名，字段值                 | void   |
| LT(string, int)    | 小于条件       | 字段名，字段值                 | void   |
| LE(string, int)    | 小于或等于条件 | 字段名，字段值                 | void   |
| limit(int)         | 记录选取条件   | 返回多少条记录                 | void   |
| limit(int, int)    | 记录选取条件   | 记录启始行位置，返回多少条记录 | void   |

### Table合约

用于对表进行增删改查操作的对象，其接口如下：

| 接口                             | 功能              | 参数                           | 返回值                    |
| -------------------------------- | ----------------- | ------------------------------ | ------------------------- |
| select(string, Condition)        | 查询数据          | 主键值，过滤条件对象           | 返回Entris的地址          |
| insert(string, Entry)            | 插入数据          | 主键值，记录对象               | 返回insert影响的行数      |
| update(string, Entry, Condition) | 更新数据          | 主键值，记录对象，过滤条件对象 | 返回update影响的行数      |
| remove(string, Condition)        | 删除数据          | 主键值，过滤条件对象           | 返回remove影响的行数      |
| newEntry()                       | 创建Entry对象     | 无                             | 返回新的Entry合约地址     |
| newCondition()                   | 创建Condition对象 | 无                             | 返回新的Condition合约地址 |

## AssetLeasingTable.sol

AssetLeasing.sol的改版，引入Table.sol，将结构体不再维护`Asset结构体（资产）`、`Debt结构体（账单）`、`mapping(string => Asset) private assets`以及`mapping(address => Debt[]) private debts`，而是在数据库中创建`t_assets表`和`t_debts表`，来维护资产和账单
