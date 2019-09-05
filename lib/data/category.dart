import '../utils/HttpUtils.dart';
// 获取安装地址
Future get categoryData async {
  List CategoryItems =[];
  Map<String, String> params = {'objfun':'getIndexCategory'};
  await HttpUtils.dioappi('Shop/getIndexData', params).then((response){
    var cateliest = response["items"];
    cateliest.forEach((ele) {
      if (ele.isNotEmpty) {
        CategoryItems.add(ele);
      }
    });
  });
  return CategoryItems;
}

/*var categoryData = [
  {
    "name": "推荐专区",
    "banner": "https://yanxuan.nosdn.127.net/38b49a2863971efec7ec9b6ad3c0f96a.png",
    "list": [
      {
        "name": "好货推荐",
        "icon": "https://yanxuan.nosdn.127.net/14bbdfb252b4ce346b8e9d019bb5b677.png"
      },
      {
        "name": "999+好评",
        "icon": "https://yanxuan.nosdn.127.net/756fc45b73941c43dc2e7d84b9aa8c08.png"
      },
      {
        "name": "都在搜",
        "icon": "https://yanxuan.nosdn.127.net/3f09367f18fd46526b3a269f24ad2000.png"
      },
      {
        "name": "居家新气象",
        "icon": "https://yanxuan.nosdn.127.net/1641653d7cc08fdf2559b6385d90b231.png"
      },
      {
        "name": "清扫季",
        "icon": "https://yanxuan.nosdn.127.net/80e1c646844df3a46a0aa30e19b41716.png"
      },
      {
        "name": "火锅轰趴",
        "icon": "https://yanxuan.nosdn.127.net/10ceea25caee323abf4e5d26d74cb1d4.png"
      },
      {
        "name": "新年送爸妈",
        "icon": "https://yanxuan.nosdn.127.net/ae5944b93150cf17bbebc3ba850d3f55.png"
      },
      {
        "name": "新年送给他",
        "icon": "https://yanxuan.nosdn.127.net/2c617ed61ab4769e552912c5093ff125.png"
      },
      {
        "name": "新年送给她",
        "icon": "https://yanxuan.nosdn.127.net/752b97d40ee10b826d16a0d6e2ffb8e8.png"
      },
      {
        "name": "新年送孩子",
        "icon": "https://yanxuan.nosdn.127.net/4cb504b640d917efcccf5fe6c73f6428.png"
      },
      {
        "name": "出游攻略",
        "icon": "https://yanxuan.nosdn.127.net/fc8ae14f8366c7dbaed31ba14a38bad5.png"
      },
      {
        "name": "除霾好物",
        "icon": "https://yanxuan.nosdn.127.net/7133cb4594d6ecaeadebeeb5114b7e78.png"
      },
      {
        "name": "专属定制",
        "icon": "https://yanxuan.nosdn.127.net/d06244d5ba0f87501a0700792a1b1e32.png"
      },
      {
        "name": "原创设计",
        "icon": "https://yanxuan.nosdn.127.net/7d216dfc4a4fe792080d5c63f4a2dc6f.png"
      }
    ]
  },
  {
    "name": "冬季专区",
    "banner": "https://yanxuan.nosdn.127.net/26be5a2b9162eef2aa95985ae20aced2.jpg",
    "list": [
      {
        "name": "全球购",
        "icon": "https://yanxuan.nosdn.127.net/fc87526ae9be33dfa45800567ec735d3.png"
      },
      {
        "name": "贪嘴小食",
        "icon": "https://yanxuan.nosdn.127.net/707a86591ac5714b4517474c8af38a17.png"
      },
      {
        "name": "出游精选",
        "icon": "https://yanxuan.nosdn.127.net/d997da3d78408efb74b86a1fc34dcf90.png"
      },
      {
        "name": "保暖家居",
        "icon": "https://yanxuan.nosdn.127.net/c82f6ac299031773f4551dae0cc559fa.png"
      },
      {
        "name": "拒绝贴膘",
        "icon": "https://yanxuan.nosdn.127.net/8d8c6dbb63565ef065619ef1038fb462.png"
      },
      {
        "name": "冬季家电",
        "icon": "https://yanxuan.nosdn.127.net/aa9d3c8dd65070df7ab41e9fd4964ca2.png"
      },
      {
        "name": "舒适床品",
        "icon": "https://yanxuan.nosdn.127.net/50c65277275790dcca741222ac6115b4.png"
      },
      {
        "name": "方便速食",
        "icon": "https://yanxuan.nosdn.127.net/682b084019c74bcce7c322e0ec0ecd9a.png"
      },
      {
        "name": "祛寒茶饮",
        "icon": "https://yanxuan.nosdn.127.net/e31a3e2d6c63cc00ed9d137ec5d10147.png"
      },
      {
        "name": "初冬新装",
        "icon": "https://yanxuan.nosdn.127.net/989d19ba6bdccc3bc8e1d2040059ae7b.png"
      },
      {
        "name": "冬季新装",
        "icon": "https://yanxuan.nosdn.127.net/7bd93dd6bb474ecfaed954f01809feb8.png"
      },
      {
        "name": "冬季新装",
        "icon": "https://yanxuan.nosdn.127.net/33346c4755915110937a279577cda230.png"
      },
      {
        "name": "滋润护理",
        "icon": "https://yanxuan.nosdn.127.net/51372a24235f27e698ce609a7d2fbcba.png"
      },
      {
        "name": "暖心配饰",
        "icon": "https://yanxuan.nosdn.127.net/20dae8b4c1bca5c3dac5a3ea98d5377a.png"
      }
    ]
  },
  {
    "name": "爆品专区",
    "banner": "https://yanxuan.nosdn.127.net/19a5c9cc21979e472bba2e79067a94ca.jpg",
    "list": [
      {
        "name": "床品家装",
        "icon": "https://yanxuan.nosdn.127.net/0cbe111b280355fd9090bf588f6f4df0.png"
      },
      {
        "name": "箱包配件",
        "icon": "https://yanxuan.nosdn.127.net/424e0ea6b3c75ec700fd1b7efe1ea2a7.png"
      },
      {
        "name": "经典服饰",
        "icon": "https://yanxuan.nosdn.127.net/f96b823ee9350e7a18c7397ef9688ca9.png"
      },
      {
        "name": "电器数码",
        "icon": "https://yanxuan.nosdn.127.net/a0777e232f60263867cc05f40896c7c3.png"
      },
      {
        "name": "洗护美妆",
        "icon": "https://yanxuan.nosdn.127.net/f11898e932c793a97f67d2d663fe1986.png"
      },
      {
        "name": "零食酒水",
        "icon": "https://yanxuan.nosdn.127.net/36767852c9f6b0c2c6b2763b542a1aed.png"
      },
      {
        "name": "厨房杂货",
        "icon": "https://yanxuan.nosdn.127.net/1bfac3a8f06a100687e5b8ba91579689.png"
      },
      {
        "name": "婴童用品",
        "icon": "https://yanxuan.nosdn.127.net/e7f964b467eb1e62c7469bde5ae36f06.png"
      },
      {
        "name": "文体周边",
        "icon": "https://yanxuan.nosdn.127.net/dfaaf1078144d9733973c21bd46627b6.png"
      },
      {
        "name": "海外特色",
        "icon": "https://yanxuan.nosdn.127.net/73ac8191b033d4820def1b9211e3f91d.png"
      }
    ]
  },
  {
    "name": "居家好物",
    "banner": "https://yanxuan.nosdn.127.net/4885db0f06d2801a1823b34ed08d789f.jpg",
    "list": [
      {
        "name": "床品件套",
        "icon": "https://yanxuan.nosdn.127.net/65a7ae2867d891a241dd8291a9037c84.png"
      },
      {
        "name": "被枕",
        "icon": "https://yanxuan.nosdn.127.net/cc507ff0ce7cafc1012885a01fb1942a.png"
      },
      {
        "name": "家具",
        "icon": "https://yanxuan.nosdn.127.net/4628932649a190c464d138c9236591fa.png"
      },
      {
        "name": "灯具",
        "icon": "https://yanxuan.nosdn.127.net/d04070745e3e6b7588aba519d48ad9d6.png"
      },
      {
        "name": "布艺软装",
        "icon": "https://yanxuan.nosdn.127.net/dd9cd8d2dae44d4319ab21919021435b.png"
      },
      {
        "name": "家饰",
        "icon": "https://yanxuan.nosdn.127.net/567f5588c5c86eeca8c94413d7c45e47.png"
      },
      {
        "name": "收纳",
        "icon": "https://yanxuan.nosdn.127.net/c8af5398744d2ed87d2459ec3d29d83e.png"
      },
      {
        "name": "旅行用品",
        "icon": "https://yanxuan.nosdn.127.net/09f2f2e348111984dd2c65dd8bcbf5d8.png"
      },
      {
        "name": "晾晒除味",
        "icon": "https://yanxuan.nosdn.127.net/0001332cb0db9939076f56c1dddbad26.png"
      }
    ]
  },
  {
    "name": "鞋包配饰",
    "banner": "https://yanxuan.nosdn.127.net/fd0e88792d85ea81d7a764cc50cf3b03.jpg",
    "list": [
      {
        "name": "行李箱",
        "icon": "https://yanxuan.nosdn.127.net/5efcbeecb663e629c1bb309c7b356f60.png"
      },
      {
        "name": "女士包袋",
        "icon": "https://yanxuan.nosdn.127.net/f968b48c45f29fc1a15b6cff7f92368d.png"
      },
      {
        "name": "男士包袋",
        "icon": "https://yanxuan.nosdn.127.net/17cbeab4e5e47ef2b5fa0f2adce6cbc2.png"
      },
      {
        "name": "钱包及小皮件",
        "icon": "https://yanxuan.nosdn.127.net/cf035e09fe2fae909e5d378ccd396e56.png"
      },
      {
        "name": "女鞋",
        "icon": "https://yanxuan.nosdn.127.net/53dd392169abf4984ee5daec84510826.png"
      },
      {
        "name": "男鞋",
        "icon": "https://yanxuan.nosdn.127.net/14e2582977d60e58da4e77ec40e41b32.png"
      },
      {
        "name": "拖鞋",
        "icon": "https://yanxuan.nosdn.127.net/1f22276749f73010ae94ae6b8960d201.png"
      },
      {
        "name": "鞋配",
        "icon": "https://yanxuan.nosdn.127.net/6571b20f095e92deaf4b3f0e159b6479.png"
      },
      {
        "name": "围巾件套",
        "icon": "https://yanxuan.nosdn.127.net/373d0f37118a3eb62b58cadaba6e4657.png"
      },
      {
        "name": "袜子",
        "icon": "https://yanxuan.nosdn.127.net/cea9714c0df2b60cdad542cf7f6c0e7e.png"
      },
      {
        "name": "丝袜",
        "icon": "https://yanxuan.nosdn.127.net/be661ded0f2bd0f3cc21bd4b2c4dbb9f.png"
      },
      {
        "name": "首饰",
        "icon": "https://yanxuan.nosdn.127.net/5d189289a6623c6ae43701c1ce3f1542.png"
      },
      {
        "name": "配件",
        "icon": "https://yanxuan.nosdn.127.net/d862cec3c88eb0619202cab232992809.png"
      },
      {
        "name": "眼镜",
        "icon": "https://yanxuan.nosdn.127.net/1d653f706fb834937a3d1c29e5725618.png"
      }
    ]
  },
  {
    "name": "服装配饰",
    "banner": "https://yanxuan.nosdn.127.net/44edf688340235bffd1ab037b3737874.jpg",
    "list": [
      {
        "name": "男式外套",
        "icon": "https://yanxuan.nosdn.127.net/1f44908a54d0a855d376d599372738d4.png"
      },
      {
        "name": "针织衫/卫衣",
        "icon": "https://yanxuan.nosdn.127.net/5d343169a0259a857591d11498dcc3c6.png"
      },
      {
        "name": "男式裤装",
        "icon": "https://yanxuan.nosdn.127.net/0db932c899b45c0260f00cbfb195e46c.png"
      },
      {
        "name": "男式牛仔",
        "icon": "https://yanxuan.nosdn.127.net/5caca392597f8b0ab3103e02e916250e.png"
      },
      {
        "name": "男式衬衫",
        "icon": "https://yanxuan.nosdn.127.net/883ddd00354e359359a63847ba5d2395.png"
      },
      {
        "name": "男式T恤/POLO",
        "icon": "https://yanxuan.nosdn.127.net/fada7f7b322eea4ba484fcc6175ad720.png"
      },
      {
        "name": "女式外套",
        "icon": "https://yanxuan.nosdn.127.net/86c3f81ba73ed80f32b19eafa10a49e9.png"
      },
      {
        "name": "女式针织衫/卫衣",
        "icon": "https://yanxuan.nosdn.127.net/c835be53f593dbbd1d31957f83465828.png"
      },
      {
        "name": "女式裤装",
        "icon": "https://yanxuan.nosdn.127.net/285478d84397b7bdc4bc7b46faa856da.png"
      },
      {
        "name": "女式牛仔",
        "icon": "https://yanxuan.nosdn.127.net/a3b03ac46eee056d1642c548bf1b4021.png"
      },
      {
        "name": "女式裙装",
        "icon": "https://yanxuan.nosdn.127.net/a60f2c44aae43b982cb2ffb2a961b331.png"
      },
      {
        "name": "女式T恤/POLO",
        "icon": "https://yanxuan.nosdn.127.net/9a8fb3ac449cda8e1ae64840ee137a5e.png"
      },
      {
        "name": "女式衬衫",
        "icon": "https://yanxuan.nosdn.127.net/6fa4dfdb7e036df499217be61327e1a0.png"
      },
      {
        "name": "男式运动上装",
        "icon": "https://yanxuan.nosdn.127.net/87e3129e372b7ebf73767f10be8a15a2.png"
      },
      {
        "name": "女式运动上装",
        "icon": "https://yanxuan.nosdn.127.net/c88fac329a5562d3ef40a5a0a1612e27.png"
      },
      {
        "name": "男式运动下装",
        "icon": "https://yanxuan.nosdn.127.net/a1a82637fc8e1ab9eafdd7ae3eec4d4f.png"
      },
      {
        "name": "运动下装",
        "icon": "https://yanxuan.nosdn.127.net/4088b6af21f8174909d62084848ef198.png"
      },
      {
        "name": "男式户外",
        "icon": "https://yanxuan.nosdn.127.net/76b81baf198ba4b682d31905f39e0265.png"
      },
      {
        "name": "女式户外",
        "icon": "https://yanxuan.nosdn.127.net/f973a931032734095cf7465245e77ec1.png"
      },
      {
        "name": "男家居服",
        "icon": "https://yanxuan.nosdn.127.net/3ee1a7cc33a6ffe0f30b526a438a592f.png"
      },
      {
        "name": "女家居服",
        "icon": "https://yanxuan.nosdn.127.net/3f34c856b84d075920543deca4615e7c.png"
      },
      {
        "name": "男式内裤",
        "icon": "https://yanxuan.nosdn.127.net/fe6f52c6d2644e4da385d42c4a77d558.png"
      },
      {
        "name": "女式内裤",
        "icon": "https://yanxuan.nosdn.127.net/f2283e51a6aef86b38c8c97ea28a03ae.png"
      },
      {
        "name": "女式内衣",
        "icon": "https://yanxuan.nosdn.127.net/51284dd9a3773f522716ae1c95344ed2.png"
      },
      {
        "name": "男式内衣",
        "icon": "https://yanxuan.nosdn.127.net/8ecd72cca1d34fde7fb5ec382b87925f.png"
      },
      {
        "name": "Yessing上装",
        "icon": "https://yanxuan.nosdn.127.net/52b47f2b4ecf51e7f21aa7bfb590af54.png"
      },
      {
        "name": "Yessing下装",
        "icon": "https://yanxuan.nosdn.127.net/84c5cc995f15153d2f92916e4828c0e1.png"
      }
    ]
  },
  {
    "name": "家用电器",
    "banner": "https://yanxuan.nosdn.127.net/57b6c260263d6e716ab7ed13e935fc8e.jpg",
    "list": [
      {
        "name": "生活电器",
        "icon": "https://yanxuan.nosdn.127.net/94a9785d8193bb4883a363be01d80ad5.png"
      },
      {
        "name": "厨房电器",
        "icon": "https://yanxuan.nosdn.127.net/adb063a460997674061bfdeda9d6b811.png"
      },
      {
        "name": "个护健康",
        "icon": "https://yanxuan.nosdn.127.net/0aaec6f7f14844e9f2286e0b0dadc1d4.png"
      },
      {
        "name": "数码",
        "icon": "https://yanxuan.nosdn.127.net/f78786f5aec13e9b4cb3615fb3690a58.png"
      },
      {
        "name": "影音娱乐",
        "icon": "https://yanxuan.nosdn.127.net/d8ff158e5e3cfe6d38fed41418864ec5.png"
      }
    ]
  },
  {
    "name": "洗护美妆",
    "banner": "https://yanxuan.nosdn.127.net/8aa5410d9d8fe87cf4da7715531c70b3.jpg",
    "list": [
      {
        "name": "纸品湿巾",
        "icon": "https://yanxuan.nosdn.127.net/c0ea432f052cb2f1f21edc59233b7608.png"
      },
      {
        "name": "家庭清洁",
        "icon": "https://yanxuan.nosdn.127.net/5fe9493e92ad818535f948c1517d183e.png"
      },
      {
        "name": "浴室用具",
        "icon": "https://yanxuan.nosdn.127.net/84f850b88650df61ecc5bc3ec1466fd8.png"
      },
      {
        "name": "毛巾浴巾",
        "icon": "https://yanxuan.nosdn.127.net/e4e5bb81db7afa070b2ba6145f717ead.png"
      },
      {
        "name": "美妆",
        "icon": "https://yanxuan.nosdn.127.net/2db8e5ce7ea802122843b071d124a711.png"
      },
      {
        "name": "香水香氛",
        "icon": "https://yanxuan.nosdn.127.net/1ab20eadf2965962b76f567465b9eda7.png"
      },
      {
        "name": "口腔护理",
        "icon": "https://yanxuan.nosdn.127.net/a92adb8489e22123c76e4868828373ed.png"
      },
      {
        "name": "身体护理",
        "icon": "https://yanxuan.nosdn.127.net/7ef2cb04dd173ae0905d451679727bd0.png"
      },
      {
        "name": "洗发护发",
        "icon": "https://yanxuan.nosdn.127.net/1e9c9f3b26824431c21793ce8e64df04.png"
      },
      {
        "name": "女性用品",
        "icon": "https://yanxuan.nosdn.127.net/701ef1375da3f6d99368f4599afdcdf2.png"
      }
    ]
  },
  {
    "name": "饮食酒水",
    "banner": "https://yanxuan.nosdn.127.net/6592880afe48eed2877923a6cafd8089.jpg",
    "list": [
      {
        "name": "饼干糕点",
        "icon": "https://yanxuan.nosdn.127.net/f8d152f1f6f4b0072dcbf10dc2983fe6.png"
      },
      {
        "name": "小食糖巧",
        "icon": "https://yanxuan.nosdn.127.net/63e96c2a27d6a4d67e8feeaaa5ba9c7e.png"
      },
      {
        "name": "坚果炒货",
        "icon": "https://yanxuan.nosdn.127.net/1d0d218887aa43ea3d74a4dcb8965d2d.png"
      },
      {
        "name": "肉类零食",
        "icon": "https://yanxuan.nosdn.127.net/b7f1f3360d22c5a0c9feed8cbe17885c.png"
      },
      {
        "name": "蜜饯果干",
        "icon": "https://yanxuan.nosdn.127.net/2be45b99b4409c4149412a74f2eaf387.png"
      },
      {
        "name": "冲调饮品",
        "icon": "https://yanxuan.nosdn.127.net/3d70af62c5461e795644b12721508372.png"
      },
      {
        "name": "茶包花茶",
        "icon": "https://yanxuan.nosdn.127.net/fb30ea6fc9e87d768200c70511a14b08.png"
      },
      {
        "name": "传统茗茶",
        "icon": "https://yanxuan.nosdn.127.net/34dc2c9d61f0df6d472820ac28940ce3.png"
      },
      {
        "name": "方便食品",
        "icon": "https://yanxuan.nosdn.127.net/559b5d22eb9d4164d7b613f6a8d22836.png"
      },
      {
        "name": "米面粮油",
        "icon": "https://yanxuan.nosdn.127.net/51b86357c5e34b77e3bb866b1cff15dc.png"
      },
      {
        "name": "南北干货",
        "icon": "https://yanxuan.nosdn.127.net/bbb7bf16b78265062dad3be66724f779.png"
      },
      {
        "name": "调味酱菜",
        "icon": "https://yanxuan.nosdn.127.net/84ca992ed0f3b733b1d71499a14532bb.png"
      },
      {
        "name": "酒类",
        "icon": "https://yanxuan.nosdn.127.net/3698a22b151359f4c1c55f565909fef8.png"
      },
      {
        "name": "乳品饮料",
        "icon": "https://yanxuan.nosdn.127.net/9b04ab23f967ef43d08bef7220452ff4.png"
      },
      {
        "name": "果鲜肉蛋",
        "icon": "https://yanxuan.nosdn.127.net/bbb5ae00927c496676dc1747989b91b7.png"
      },
      {
        "name": "网易黑猪",
        "icon": "https://yanxuan.nosdn.127.net/fc7770efb186d8b440e6f8b07dc0446b.png"
      },
      {
        "name": "海外美食",
        "icon": "https://yanxuan.nosdn.127.net/fe74ff4076d40d2c068d18feb6831a38.png"
      }
    ]
  },
  {
    "name": "餐具厨房",
    "banner": "https://yanxuan.nosdn.127.net/70e6dda08179a8df081d8a4f78b28e0a.jpg",
    "list": [
      {
        "name": "锅具",
        "icon": "https://yanxuan.nosdn.127.net/10a143a382aaf8b8de1f533a1d3b6760.png"
      },
      {
        "name": "清洁保鲜",
        "icon": "https://yanxuan.nosdn.127.net/fdec112d77ab0c5083e6b2c53531df7d.png"
      },
      {
        "name": "厨房配件",
        "icon": "https://yanxuan.nosdn.127.net/a2e37687f68cf5cf9b5f5a54803e6171.png"
      },
      {
        "name": "刀剪砧板",
        "icon": "https://yanxuan.nosdn.127.net/2783b73b3631d9c71a3c602000e393c8.png"
      },
      {
        "name": "餐具",
        "icon": "https://yanxuan.nosdn.127.net/9fec1d39f6753fbc727b1ff76d9c810c.png"
      },
      {
        "name": "水具杯壶",
        "icon": "https://yanxuan.nosdn.127.net/95237ea2c4867a7b6d21e69245316af1.png"
      },
      {
        "name": "咖啡具酒具",
        "icon": "https://yanxuan.nosdn.127.net/318f9ae4afc1aff32515de0f73e66f80.png"
      }
    ]
  },
  {
    "name": "母婴亲子",
    "banner": "https://yanxuan.nosdn.127.net/9e5cebe56f9b6ee9debf2ec778c204e0.jpg",
    "list": [
      {
        "name": "婴童洗护",
        "icon": "https://yanxuan.nosdn.127.net/1b30a77ba7155bfa1600bf575f36b988.png"
      },
      {
        "name": "婴童床品",
        "icon": "https://yanxuan.nosdn.127.net/16f1a79588cfd7ac1fc5632b5b36c97c.png"
      },
      {
        "name": "毛巾口水巾",
        "icon": "https://yanxuan.nosdn.127.net/7a347426bb41f4e5221001855dcbc65c.png"
      },
      {
        "name": "儿童家具收纳",
        "icon": "https://yanxuan.nosdn.127.net/e7141bcb899e68defef64a4b2e4e0b6e.png"
      },
      {
        "name": "喂养用品",
        "icon": "https://yanxuan.nosdn.127.net/18f14044baa8b3c52a3170f67b564244.png"
      },
      {
        "name": "玩具",
        "icon": "https://yanxuan.nosdn.127.net/db8c57a1919ccf4042044d5cfafb1ab8.png"
      },
      {
        "name": "童车童床",
        "icon": "https://yanxuan.nosdn.127.net/8dcc97dc6aff9ca86ab5bd891ed784ec.png"
      },
      {
        "name": "童鞋",
        "icon": "https://yanxuan.nosdn.127.net/9ccd42986d8280066a5a99a9b03f06d0.png"
      },
      {
        "name": "童包",
        "icon": "https://yanxuan.nosdn.127.net/2bd5b0347af63c1dfa0c1f5a29ac5e9a.png"
      },
      {
        "name": "新生儿服装",
        "icon": "https://yanxuan.nosdn.127.net/b0cc6e8ef277da3161272ab1e38bd8a3.png"
      },
      {
        "name": "小童服装",
        "icon": "https://yanxuan.nosdn.127.net/7361a46e64be05d6bba139aa5b5ef0a6.png"
      },
      {
        "name": "中大童服装",
        "icon": "https://yanxuan.nosdn.127.net/26291e8fe052fd5ea608d1f4677aa299.png"
      },
      {
        "name": "婴童配搭",
        "icon": "https://yanxuan.nosdn.127.net/41376989e1606ba32f1876c3f7891af4.png"
      },
      {
        "name": "孕产内衣",
        "icon": "https://yanxuan.nosdn.127.net/e18bbf285164afa04800112e1a58df62.png"
      },
      {
        "name": "孕妈装",
        "icon": "https://yanxuan.nosdn.127.net/53372fd808c8cd06d3db3b1b2afedc00.png"
      },
      {
        "name": "妈咪用品",
        "icon": "https://yanxuan.nosdn.127.net/ab2ad0532fefc6a42f4bc329452ff69b.png"
      }
    ]
  },
  {
    "name": "文体文具",
    "banner": "https://yanxuan.nosdn.127.net/ac93580ecfd06927f8e76a6cc3d1c46e.jpg",
    "list": [
      {
        "name": "文具",
        "icon": "https://yanxuan.nosdn.127.net/e074795f61a83292d0f20eb7d124e2ac.png"
      },
      {
        "name": "运动户外",
        "icon": "https://yanxuan.nosdn.127.net/a15c33fdefe11388b6f4ed5280919fdd.png"
      },
      {
        "name": "乐器唱片",
        "icon": "https://yanxuan.nosdn.127.net/77847b8066205331eb22c9c363e3740e.png"
      },
      {
        "name": "礼品卡",
        "icon": "https://yanxuan.nosdn.127.net/1266f0767a3f67298a40574df0d177fb.png"
      },
      {
        "name": "游戏点卡",
        "icon": "https://yanxuan.nosdn.127.net/2b9dc4c3afd6176327639ff2f1e74a49.png"
      },
      {
        "name": "云音乐周边",
        "icon": "https://yanxuan.nosdn.127.net/6e7e5c58f1b6c7e8e6e9cc51db6d93d5.png"
      },
      {
        "name": "暴雪周边",
        "icon": "https://yanxuan.nosdn.127.net/ae1d3e3fa2d25cb77ed78cdeca18aa9a.png"
      },
      {
        "name": "我的世界",
        "icon": "https://yanxuan.nosdn.127.net/9cedd5b2d498569d33725fd062e88639.png"
      },
      {
        "name": "梦幻西游",
        "icon": "https://yanxuan.nosdn.127.net/36711325781ca50fdfe234489fca973e.png"
      },
      {
        "name": "大话西游",
        "icon": "https://yanxuan.nosdn.127.net/470a017f508e9a18f3068be7b315e14b.png"
      },
      {
        "name": "阴阳师",
        "icon": "https://yanxuan.nosdn.127.net/468009f99e26648811601cb834c8608f.png"
      },
      {
        "name": "游戏印象",
        "icon": "https://yanxuan.nosdn.127.net/326a30b2e5acf3d98d73ebaebd0a5775.png"
      },
      {
        "name": "文创周边",
        "icon": "https://yanxuan.nosdn.127.net/86b11b0ea90dc612b9da188192fdd055.png"
      },
      {
        "name": "影视周边",
        "icon": "https://yanxuan.nosdn.127.net/52383f67f67d6e116b772d4f542f97e7.png"
      },
      {
        "name": "动漫电玩",
        "icon": "https://yanxuan.nosdn.127.net/3068b57c28713dde7acebfbe53e224e5.png"
      }
    ]
  },
  {
    "name": "精品特色",
    "banner": "https://yanxuan.nosdn.127.net/2213d1089e494aaed96e9b1d7b212210.jpg",
    "list": [
      {
        "name": "进口尖货",
        "icon": "https://yanxuan.nosdn.127.net/3f58df61392637cfad5f739e05d6ec6a.png"
      },
      {
        "name": "日本馆",
        "icon": "https://yanxuan.nosdn.127.net/2a403bdcb6dbf06f7fa0cfdc6bdef7c7.png"
      },
      {
        "name": "韩国馆",
        "icon": "https://yanxuan.nosdn.127.net/a1e185658914642b71a7d51170108195.png"
      },
      {
        "name": "东南亚馆",
        "icon": "https://yanxuan.nosdn.127.net/6749537a2b6a1619e42aa8e94a1b2d2c.png"
      },
      {
        "name": "欧美馆",
        "icon": "https://yanxuan.nosdn.127.net/e60a882e50816f2400ec33669f74e000.png"
      },
      {
        "name": "澳新馆",
        "icon": "https://yanxuan.nosdn.127.net/c280d991c26084534fada20ad8c8ffb5.png"
      },
      {
        "name": "智造馆",
        "icon": "https://yanxuan.nosdn.127.net/90cb73a8402bd246497ccab1589b18c5.png"
      },
      {
        "name": "味央馆",
        "icon": "https://yanxuan.nosdn.127.net/5298d0b7669dcdd0caa53c5a90667394.png"
      },
      {
        "name": "Yessing馆",
        "icon": "https://yanxuan.nosdn.127.net/13111ba071c5ac814e4a8eed9a65cf69.png"
      },
      {
        "name": "国风馆",
        "icon": "https://yanxuan.nosdn.127.net/7fce16b6d9466aa870989cb0c3860a68.png"
      },
      {
        "name": "东方草木馆",
        "icon": "https://yanxuan.nosdn.127.net/915a6f1e93a0f422021325c48863b331.png"
      },
      {
        "name": "推荐馆",
        "icon": "https://yanxuan.nosdn.127.net/ca7287d399e71f7e10a722fcfcb725b6.png"
      }
    ]
  }
];
*/