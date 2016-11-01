# ASLinq
ASLinq是什么？
ASLinq是模仿C#中的Linq（https://msdn.microsoft.com/zh-cn/library/bb397926.aspx）在ActionScript3中实现部分功能的类库。
严格上说它应该属于Find，算不上ActionScript3版的LINQ。仅仅是为了好记才叫ASLinq。

有什么用？
可以很快的从集合数据中获取你想要的，不再需要写for.....if....，代码更加简单,干净.


该什么用？
    private var people:IEnumerable = new ASLinq([ 
		    {name:"Allen Frances", age:11, canCode:false}, 
		    {name:"Burke Madison", age:50, canCode:true}, 
		    {name:"David Charles", age:33, canCode:true}, 
		    {name:"Connor Morgan", age:50, canCode:false}, 
		    {name:"Everett Frank", age:16, canCode:true} 
		]
   ASLinq（）构造必须是一个Array。
   
   var result : IEnumerable = people.where(function(x) { return x.name == "Burke Madison"; });
    返回的是满足t条件的Array。
    如：
      var data:IEnumerable = new ASLinq([6, 8, 3, 4, 7]);
			var result:IEnumerable = data.where(
				function(x) {return x > 5;}
			);
      //result = [6, 8, 7]   
      
