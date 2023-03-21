// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

// 作者模块

contract Author {
    //取款事件
    event AuthorWithdraw( address indexed to, uint time, uint amount );
    
    mapping(address => author) public authorInfo;
    mapping(uint => address) public authorBelong;
    uint256 private authorID = 1; //从1开始，没有注册过的用户的id为0
    address public admin;

    // 作者信息结构体
    struct author {
        uint256 aid; //作者id
        uint256 reg;//注册时间
        // string portrait; //头像
        string bio; //签名
        string name; //名字
        // string thumbnail; //海报
        bool status; //状态 是否被禁用,true可以使用，false被禁用
    }

    mapping(uint256 => article) public articleInfo;  //文章id对应文章内容
    mapping(uint256 => uint) public articleBelongAuthor; //文章id对应作者ID
    mapping(uint256 => uint256[]) public authorArticleList; //作者id对应他自己的所有文章id
    uint256 private articleID = 1; //文章id

    // 文章信息结构体
     //使用结构体处理 stack deep问题
    struct articleVariable {
        uint256 deadline;  //截止时间
        bool needPay; //是否需要支付
        uint256 payCash; //支付的钱数
        uint8 payMethods; //支付方式  0 免费 1 强制付费 2 表示打赏
        uint8 rewardPercent; //分佣
        string title; //文章标题
        // 把文章内容，描述移到ipfs上  链上只存哈希
        // string decription; //文章描述 （链接，存在ipfs上）
        // string content; //文章内容 （链接，存在ipfs上）
    }
    struct article {
        uint256 arid; //文章id
        uint256 issue; // 发布时间
        uint256 deadline;  //截止时间
        bool needPay; //是否需要支付
        uint256 payCash; //支付的钱数
        uint8 payMethods; //支付方式  0 免费 1 强制付费 2 表示打赏
        uint8 rewardPercent; //分佣(给推广者的佣金比例)
        string title; //文章标题
        // 把文章内容，描述移到ipfs上  链上只存哈希
        // string decription; //文章描述 （链接，存在ipfs上）
        // string content; //文章内容 （链接，存在ipfs上）
        bool status; //文章是否被禁用
        // articleVariable articleContent;
    }

     // 作者
    mapping(uint => uint) public authorBalance; //作者id =》作者钱包
    mapping(uint => uint[]) public authorFansPay;  // 作者id =》 订单ID

    constructor(address _admin){
        admin = _admin;
    }

    // 管理员修改器
    modifier onlyAdmin {
        require(msg.sender == admin, "you are not admin");
        _;
    }
    //确定是不是作者本人
    modifier onlyAuthor(uint _aid) {
        require(_aid > 0);
        require(authorInfo[msg.sender].status,"you are in black list"); //确定是否被禁用
        require(authorInfo[msg.sender].aid == _aid, "you are not owner");
        _;
    }

    // 修改管理员
    function changeAdmin(address _newAddr) public onlyAdmin {
        admin = _newAddr;
    }

    // 判断是否已经注册过
    function _isAdd(address _author) internal view returns(bool){
        uint id = authorInfo[_author].aid;
        bool status = id > 0 ? true : false;
        return status;
    }

    //新增作者
    function addAuthorInfo(
        // string calldata _portrait, //头像
        string calldata _bio, //签名
        string calldata _name //名字
        // string calldata _thumbnail //海报
    ) external {
        require(msg.sender != address(0));
        require(!_isAdd(msg.sender),"exist this author address, can not add new");
        uint reg = block.timestamp;
        // authorInfo[msg.sender] = author(authorID,reg,_portrait,_bio,_name,_thumbnail,true);
        authorInfo[msg.sender] = author(authorID,reg,_bio,_name,true);
        authorBelong[authorID] = msg.sender;
        authorID++;
    }

    // 作者修改个人资料
    function modifyAuthorInfo(
        uint256 _aid,
        // string calldata _portrait, //头像
        string calldata _bio, //签名
        string calldata _name //名字
        // string calldata _thumbnail //海报
    ) external onlyAuthor(_aid) {
        uint reg = authorInfo[msg.sender].reg;
        // authorInfo[msg.sender] = author(_aid,reg,_portrait,_bio,_name,_thumbnail,true);
        authorInfo[msg.sender] = author(_aid,reg,_bio,_name,true);
    }

    // 管理员修改作者状态
    function changeAuthorStatus(uint _aid, bool _status) public onlyAdmin {
        require(_aid != 0);
        address addr = authorBelong[_aid];
        authorInfo[addr].status = _status;
    }


    // 文章相关
    // 创建文章
    // 1,[1679225392,true,1000000000000000000,2,50,"123","123","123"]
    function addArticle(
        uint _aid, //作者id
        // uint256 _deadline,  //截止时间
        // bool _needPay, //是否需要支付
        // uint256 _payCash, //支付的钱数
        // uint8 _payMethods, //支付方式  0 免费 1 强制付费 2 表示打赏
        // uint8 _rewardPercent, //分佣
        // string calldata _title, //文章标题

        // 把文章内容，描述移到ipfs上  链上只存哈希
        // string calldata _decription, //文章描述 （链接，存在ipfs上）
        // string calldata _content //文章内容 （链接，存在ipfs上）

        articleVariable memory contentData  //使用结构体处理 stack deep问题

    ) external onlyAuthor(_aid) {
        require(msg.sender != address(0));
        uint256 issue = block.timestamp;
        articleInfo[articleID] = article(_aid, issue, contentData.deadline,contentData.needPay ,contentData.payCash,contentData.payMethods,contentData.rewardPercent,contentData.title,true);
        articleBelongAuthor[articleID] = _aid;
        authorArticleList[_aid].push(articleID);
        articleID++;
    }

    //作者修改文章
    function modifyArticle(
        uint _arid, //文章id
        // uint256 _deadline,  //截止时间
        // bool _needPay, //是否需要支付
        // uint256 _payCash, //支付的钱数
        // uint8 _payMethods, //支付方式  0 免费 1 强制付费 2 表示打赏
        // uint8 _rewardPercent, //分佣
        // string calldata _title, //文章标题
        
        // 把文章内容，描述移到ipfs上  链上只存哈希
        // string calldata _decription, //文章描述 （链接，存在ipfs上）
        // string calldata _content //文章内容 （链接，存在ipfs上）

        articleVariable memory contentData //使用结构体处理 stack deep问题

    ) external {
        require(_arid > 0);
        uint aid = articleBelongAuthor[_arid];
        require(aid == authorInfo[msg.sender].aid, "you are not owner");
        uint256 issue = articleInfo[_arid].issue;
        bool status = articleInfo[_arid].status;
        articleInfo[_arid] = article(aid, issue, contentData.deadline,contentData.needPay ,contentData.payCash,contentData.payMethods,contentData.rewardPercent,contentData.title,status);
    }

    // 管理员对文章状态的修改
    function changeArticleStatus(uint256 _arid, bool _status) public onlyAdmin {
        require(_arid != 0);
        articleInfo[_arid].status = _status;
    }


    // 取款函数(作者)
    function authorWithdraw() external {
        uint aid = authorInfo[msg.sender].aid;
        require(authorBalance[aid] > 0);
        require(msg.sender != address(0));
        uint amount = authorBalance[aid];
        payable(msg.sender).transfer(amount);

        emit AuthorWithdraw(msg.sender,block.timestamp,amount);
        authorBalance[aid] = 0;

    }
}