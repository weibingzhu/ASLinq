package {
	import flash.utils.Dictionary;
	
	public class UnitTests {
		
		public function UnitTests()
		{
		}
		
		private var people:IEnumerable = new ASLinq([ 
		    {name:"Allen Frances", age:11, canCode:false}, 
		    {name:"Burke Madison", age:50, canCode:true}, 
		    {name:"David Charles", age:33, canCode:true}, 
		    {name:"Connor Morgan", age:50, canCode:false}, 
		    {name:"Everett Frank", age:16, canCode:true} 
		]);
		
		private var customers:IEnumerable = new ASLinq([ 
		    {id:1, name:"Gotts"}, 
		    {id:2, name:"Valdes"}, 
		    {id:3, name:"Gauwin"}, 
		    {id:4, name:"Deane"}, 
		    {id:5, name:"Zeeman"} 
		]);
 
		private var orders:IEnumerable = new ASLinq([ 
		    {id:1, description:"Order 1"}, 
		    {id:1, description:"Order 2"}, 
		    {id:4, description:"Order 3"}, 
		    {id:4, description:"Order 4"}, 
		    {id:5, description:"Order 5"} 
		]); 
 
		
		public function test_aggregate():void
		{
			var data:IEnumerable = new ASLinq([-1, 1, 2, 3, 4, 5]);
			var result:int = data.aggregate(function(x, y) {return x + y;});
			trace("assertEquals",result, 14);
			result = data.aggregate(function(x, y) {return x + y;}, 10, function(x) {return 2*x;});
			trace("assertEquals",result, 48);
			data = new ASLinq();
			result = data.aggregate(function(x, y) {return x + y;}, 10, function(x) {return 2*x;});
			trace("assertEquals",result, 0);
		}
		 
		public function test_all():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:Boolean = data.all(function(x) {return x < 4;});
			trace("assertFalse",result);
			result = data.all(function(x) {return x < 10;});
			trace("assertTrue",result);
			data = new ASLinq();
			result = data.all(function(x) {return x < 10;});
			trace("assertTrue",result);
		}
		
		public function test_any():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:Boolean = data.any(function(x) {return x < 4;});
			trace("assertTrue",result);
			result = data.any(function(x) {return x > 10;});
			trace("assertFalse",result);
			data = new ASLinq();
			result = data.any(function(x) {return x < 10;});
			trace("assertFalse",result);
		}
		
		public function test_asEnumerable():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:* = data.asEnumerable();
			trace("assertTrue",result is IEnumerable);
		}
		
		public function test_average():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var av:Number = data.average(function(x) {return 2*x;});
			trace("assertEquals",av, 6);
			av = people.average(function(x) {return x.age;});
			trace("assertEquals",av , 32);
			data = new ASLinq();
			av = data.average(function(x) {return 2*x;});
			trace("assertEquals",av , NaN);
		}
		
		public function test_cast():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var expected:String = "null\nnull\nnull\nnull\nnull\n";
			var result:String = data.cast(String).print(null, true, "", false);
			trace("assertEquals",result, expected);
			expected = "1\n2\n3\n4\n5\n";
			result = data.cast(Number).print(null, true, "", false);
			trace("assertEquals",result , expected);
		}
			
		public function test_concat():void
		{
			var data1:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var data2:IEnumerable = new ASLinq([6, 7]);
			var expected:String = "1\n2\n3\n4\n5\n6\n7\n";
			var result:String = data1.concat(data2).print(null, true, "", false);
			trace("assertEquals",result, expected);
			expected = "1\n2\n3\n4\n5\n";
			result = data1.concat(new ASLinq()).print(null, true, "", false);
			trace("assertEquals",result, expected);
			expected = "6\n7\n";
			result = (new ASLinq() as IEnumerable).concat(data2).print(null, true, "", false);
			trace("assertEquals",result, expected);
		}
		
		public function test_contains():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:Boolean = data.contains(3);
			trace("assertTrue",result);
			result = data.contains(10);
			trace("assertFalse",result);
			result = people.contains({name:"David Charles", age:33, canCode:true});
			trace("assertTrue",result);
			result = people.contains({name:"David Charles", age:32, canCode:true});
			trace("assertFalse",result);
			result = people.contains({name:"David Charles", age:33});
			trace("assertFalse",result);
			result = people.contains(33, function(x, y) {return x.age == y;});
			trace("assertTrue",result);
			result = people.contains(34, function(x, y) {return x.age == y;});
			trace("assertFalse",result);
			result = (new ASLinq()).contains(null);
			trace("assertFalse",result);
			result = data.contains(null);
			trace("assertFalse",result);
		}
		
		public function test_defaultIfEmpty():void
		{
			var data:IEnumerable = new ASLinq();
			var result:IEnumerable = data.defaultIfEmpty();
			trace("assertEquals",result[0], undefined);
			data = new ASLinq([1, 2, 3, 4, 5]);
			result = data.defaultIfEmpty();
			trace("assertEquals",result.count(), 5);
		}
		
		public function test_distinct():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 2, 5]);
			var result:String = data.distinct().print(null, true, "", false);
			trace("assertEquals",result, "1\n2\n3\n5\n");
			var result2:IEnumerable = people.distinct(function(x, y) { return x.age == y.age; });
			trace("assertEquals",result2.count(), 4);
		}
		
		public function test_elementAt():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:int = data.elementAt(3);
			trace("assertEquals",result, 4);
			result = data.elementAt(10);
			trace("assertEquals",result, 0);
		}
		
		public function test_elementAtorDefault():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:int = data.elementAtorDefault(3);
			trace("assertEquals",result, 4);
			result = data.elementAtorDefault(10);
			trace("assertEquals",result, 0);
		}
		
		public function test_except():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:String = data.except(new ASLinq([3, 4])).print(null, true, "", false);
			trace("assertEquals",result, "1\n2\n5\n");
			var result2:IEnumerable = people.except(new ASLinq([
		    	{name:"Connor Morgan", age:50, canCode:false}, 
		    	{name:"Everett Frank", age:16, canCode:true}
		    ]));
			trace("assertEquals",result2.count(), 3);
		    result2 = people.except(new ASLinq(["Everett Frank", "Connor Morgan"]),
		    	function (x, y) {return x.name == y;});
			trace("assertEquals",result2.count(), 3);
		}
		
		public function test_first():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:int = data.first();
			trace("assertEquals",result, 1);
			result = data.first(function(x) { return x > 3; });
			trace("assertEquals",result, 4);
			var result2:* = data.first(function(x) { return x > 10; });
			trace("assertEquals",result2, undefined);
		}
		
		public function test_firstOrDefault():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:int = data.first();
			trace("assertEquals",result, 1);
			result = data.first(function(x) { return x > 3; });
			trace("assertEquals",result, 4);
			var result2:* = data.first(function(x) { return x > 10; });
			trace("assertEquals",result2, undefined);
		}
		
		public function test_getElementKeys():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:Array = data.getElementKeys();
			trace("assertEquals",result.length, 0);
			result = people.getElementKeys();
			trace("assertEquals",result[0], "age");
			trace("assertEquals",result[1], "canCode");
			trace("assertEquals",result[2], "name");
			result = people.getElementKeys(function(x, y) { return x < y; });
			trace("assertEquals",result[0], "name");
			trace("assertEquals",result[1], "canCode");
			trace("assertEquals",result[2], "age");
			result = people.getElementKeysDescending();
			trace("assertEquals",result[0], "name");
			trace("assertEquals",result[1], "canCode");
			trace("assertEquals",result[2], "age");
		}
		
		public function test_groupBy():void
		{
			var result:IEnumerable = people.groupBy("canCode");
			trace("assertEquals",result[0].key, "false");
			trace("assertEquals",result[1].key, "true");
			trace("assertTrue", (result[0].value as IEnumerable).sequenceEqual( new ASLinq([
				{age:11, canCode:false, name:"Allen Frances"},  
				{age:50, canCode:false, name:"Connor Morgan"}
			])) );
			trace("assertTrue", (result[1].value as IEnumerable).sequenceEqual( new ASLinq([
				{name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Everett Frank", age:16, canCode:true}
			])) );
			result = people.groupBy( 
			    function(x) {     
			        if ( x.age > 0  && x.age <= 20 ) return "adolescent"; 
			        if ( x.age > 20 && x.age <= 35 ) return "young"; 
			        if ( x.age > 35 )                return "veteran"; 
			    }, 
			    "name"            
			);
			trace("assertEquals",result[0].key, "adolescent");
			trace("assertEquals",result[1].key, "veteran");
			trace("assertEquals",result[2].key, "young");
			trace("assertTrue", (result[0].value as IEnumerable).sequenceEqual( new ASLinq([
				"Allen Frances", "Everett Frank" 
			])) );
			trace("assertTrue",(result[1].value as IEnumerable).sequenceEqual( new ASLinq([
				"Burke Madison", "Connor Morgan"
			])) );
			trace("assertTrue", (result[2].value as IEnumerable).sequenceEqual( new ASLinq([
				"David Charles"
			])) );
		}
		
		public function test_groupJoin():void
		{
			var result:IEnumerable = 
			customers.groupJoin(             
			    orders,                      
			    "id",                        
			    "id",                        
			    function(c, g) {             
			        return {customerName:c.name, orders:g.select(function(order) { return order.description; })}; 
				}
			);
			trace("assertEquals",result[0].customerName, "Gotts");
			trace("assertEquals",result[1].customerName, "Valdes");
			trace("assertEquals",result[2].customerName, "Gauwin");
			trace("assertEquals",result[3].customerName, "Deane");
			trace("assertEquals",result[4].customerName, "Zeeman");
			trace("assertEquals",result[0].orders[0], "Order 1");
			trace("assertEquals",result[0].orders[1], "Order 2");
			trace("assertEquals",result[0].orders.length, 2);
			trace("assertEquals",result[1].orders.length, 0);
			trace("assertEquals",result[2].orders.length, 0);
			trace("assertEquals",result[3].orders[0], "Order 3");
			trace("assertEquals",result[3].orders[1], "Order 4");
			trace("assertEquals",result[3].orders.length, 2);
			trace("assertEquals",result[4].orders[0], "Order 5");
			trace("assertEquals",result[4].orders.length, 1);
		}
		
		public function test_intersects():void
		{
			var data1:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var data2:IEnumerable = new ASLinq([4, 5, 6, 7]);
			var result:String = data1.intersect(data2).print(null, true, "", false);
			trace("assertEquals",result, "1\n2\n3\n4\n5\n6\n7\n")
			trace("assertEquals",result, "4\n5\n");
			result = data1.intersect(new ASLinq()).print(null, true, "", false);
			trace("assertEquals",result, "empty\n");
			result = (new ASLinq()).intersect(data2).print(null, true, "", false);
			trace("assertEquals",result, "empty\n");
			var data3:IEnumerable = new ASLinq([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}, 
		    	{id:6, name:"Reeman"}
			]);
			var result2:IEnumerable = customers.intersect(data3);
			trace("assertTrue",result2.sequenceEqual(new ASLinq([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}
			])));
			var data4:IEnumerable = new ASLinq([3, 4, 6]);
			result2 = customers.intersect(data4, function(x, y) { return x.id == y; });
			trace("assertTrue",result2.sequenceEqual(new ASLinq([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}
			])));
		}
		
		public function test_join():void
		{
			var result:IEnumerable = customers.join(      
				orders,          
				"id",            
				"id",            
				function(c, o) { 
        			return { customerName:c.name, order:o.description }; 
    			} 
			);
			trace("assertTrue",result.sequenceEqual(new ASLinq([
				{customerName:"Gotts", order:"Order 1"},  
		        {customerName:"Gotts", order:"Order 2"},  
		        {customerName:"Deane", order:"Order 3"},  
		        {customerName:"Deane", order:"Order 4"},  
		        {customerName:"Zeeman", order:"Order 5"}			
			])));
			result = customers.join(      
				orders,          
				function(x) {return x.id;},            
				function(x) {return x.id;},            
				function(c, o) { return { customerName:c.name, order:o.description }; },
    			function(x, y) { return x == y; }
			);
			trace("assertTrue",result.sequenceEqual(new ASLinq([
				{customerName:"Gotts", order:"Order 1"},  
		        {customerName:"Gotts", order:"Order 2"},  
		        {customerName:"Deane", order:"Order 3"},  
		        {customerName:"Deane", order:"Order 4"},  
		        {customerName:"Zeeman", order:"Order 5"}			
			])));
			result = (new ASLinq() as IEnumerable).join(      
				(new ASLinq()),          
				"id",            
				"id",            
				function(c, o) { 
        			return { customerName:c.name, order:o.description }; 
    			});
			trace("assertTrue",result.sequenceEqual(new ASLinq()));    		
		}
		
		public function test_last():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:int = data.last();
			trace("assertEquals",result, 5);
			result = data.last(function(x) { return x < 4; });
			trace("assertEquals",result, 3);
			var result2:* = data.last(function(x) { return x > 10; });
			trace("assertEquals",result2, undefined);
		}
		
		public function test_lastOrDefault():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:int = data.last();
			trace("assertEquals",result, 5);
			result = data.last(function(x) { return x < 4; });
			trace("assertEquals",result, 3);
			var result2:* = data.last(function(x) { return x > 10; });
			trace("assertEquals",result2, undefined);
		}
		
		public function test_max():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5, -1, 3 , 2]);
			trace("assertEquals",data.max(), 5);
			trace("assertEquals",people.max(function(x) { return x.age; }).age, 50);
			trace("assertEquals",(new ASLinq()).max(), undefined);
		}
		
		public function test_min():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5, -1, 3 , 2]);
			trace("assertEquals",data.min(), -1);
			trace("assertEquals",people.min(function(x) { return x.age; }).age, 11);
			trace("assertEquals",(new ASLinq()).min(), undefined);
		}
		
		public function test_nonPrimitives():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 
				{name:"Allen Frances", age:11, canCode:false}, 
    			{name:"Burke Madison", age:50, canCode:true} 
    		]);
			trace("assertTrue",data.nonPrimitives().sequenceEqual(new ASLinq([
				{name:"Allen Frances", age:11, canCode:false}, 
    			{name:"Burke Madison", age:50, canCode:true}
			])) );
		}
		
		public function test_ofType():void
		{
			var data:IEnumerable = new ASLinq([1, "2", "3", 4, 5]);
			trace("assertTrue",data.ofType(Number).sequenceEqual(new ASLinq([1, 4, 5])));
			trace("assertTrue",data.ofType(String).sequenceEqual(new ASLinq(["2", "3"])));
			trace("assertTrue",data.ofType(Boolean).sequenceEqual(new ASLinq()));
		}
		
		public function test_orderBy():void
		{
			var data:IEnumerable = new ASLinq([5, 3, 2, 1, 4]);
			var result:IEnumerable = data.orderBy(
					function(x) { return x; }
				);
			trace("assertEquals",result.print(null, true, "", false), "1\n2\n3\n4\n5\n");
			result = data.orderBy(
					function(x) { return x; },
					function(x, y) { return x < y; }
				);
			trace("assertEquals",result.print(null, true, "", false), "5\n4\n3\n2\n1\n");
			result = people.orderBy("name");
			trace("assertTrue",result.sequenceEqual(new ASLinq([
					{age:11, canCode:false, name:"Allen Frances"},  
					{age:50, canCode:true, name:"Burke Madison"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:33, canCode:true, name:"David Charles"}, 
					{age:16, canCode:true, name:"Everett Frank"}
			])) );
			result = people.orderBy( 
			    function(x) { return x.name; },    
			    function(x:String, y:String) {    
			        if (x.toUpperCase() < y.toUpperCase()) return +1; 
			        if (x.toUpperCase() == y.toUpperCase()) return 0; 
			        return -1;  
    			} 
 			);
			trace("assertTrue",result.sequenceEqual(new ASLinq([
					{age:16, canCode:true, name:"Everett Frank"},  
					{age:33, canCode:true, name:"David Charles"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:50, canCode:true, name:"Burke Madison"}, 
					{age:11, canCode:false, name:"Allen Frances"}
			])) );
		}
		
		public function test_orderByDescending():void
		{
			var data:IEnumerable = new ASLinq([5, 3, 2, 1, 4]);
			var result:IEnumerable = data.orderByDescending(
					function(x) { return x; }
				);
			trace("assertEquals",result.print(null, true, "", false), "5\n4\n3\n2\n1\n");
			result = people.orderByDescending("name");
			trace("assertTrue",result.sequenceEqual(new ASLinq([
					{age:16, canCode:true, name:"Everett Frank"},  
					{age:33, canCode:true, name:"David Charles"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:50, canCode:true, name:"Burke Madison"}, 
					{age:11, canCode:false, name:"Allen Frances"}
			])) );
			result = people.orderByDescending( 
			    function(x) { return x.name; }   
 			);
			trace("assertTrue",result.sequenceEqual(new ASLinq([
					{age:16, canCode:true, name:"Everett Frank"},  
					{age:33, canCode:true, name:"David Charles"},
					{age:50, canCode:false, name:"Connor Morgan"}, 
					{age:50, canCode:true, name:"Burke Madison"}, 
					{age:11, canCode:false, name:"Allen Frances"}
			])) );
		}
		
		public function test_pop():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3]);
			trace("assertEquals",data.count(), 3);
			trace("assertEquals",data.pop(), 3);
			trace("assertEquals",data.count(), 2);
			trace("assertEquals",data.pop(), 2);
			trace("assertEquals",data.count(), 1);
			trace("assertEquals",data.pop(), 1);
			trace("assertEquals",data.count(), 0);
			trace("assertEquals",data.pop(), undefined);
			trace("assertEquals",data.count(), 0);
		}
		
		public function test_primitives():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 
				{name:"Allen Frances", age:11, canCode:false}, 
    			{name:"Burke Madison", age:50, canCode:true} 
    		]);
			trace("assertTrue",data.primitives().sequenceEqual(new ASLinq([1, 2, 3])));
		}
		
		public function test_push():void
		{
			var data:IEnumerable = new ASLinq([]);
			trace("assertEquals",data.count(), 0);
			data.push(1);
			trace("assertTrue",data.sequenceEqual(new ASLinq([1])));
			data.push(2);
			trace("assertTrue",data.sequenceEqual(new ASLinq([1, 2])));
			data.push(3, 4);
			trace("assertTrue",data.sequenceEqual(new ASLinq([1, 2, 3, 4])));
		}
		
		public function test_reverse():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			trace("assertTrue",data.reverse().sequenceEqual(new ASLinq([5, 4, 3, 2, 1])));
			data = new ASLinq();
			trace("assertEquals",data.reverse().count(), 0);
		}
		
		public function test_select():void
		{
			var data:IEnumerable = new ASLinq(["orange", "banana", "apple", "grapes", "mango"]);
			trace("assertTrue",
				data.select(function(x) { return x.length; }).sequenceEqual(
				new ASLinq([6, 6, 5, 6 , 5])));
			trace("assertTru",
				data.select(function(x) { return { type:x, length:x.length }; }).sequenceEqual(
				new ASLinq([
					{length:6, type:"orange"},  
					{length:6, type:"banana"}, 
					{length:5, type:"apple"},  
					{length:6, type:"grapes"},  
					{length:5, type:"mango"} 
				])));
			trace("assertTrue",
				people.select("name", "age").sequenceEqual(
				new ASLinq([
					{name:"Allen Frances", age:11}, 
				    {name:"Burke Madison", age:50}, 
				    {name:"David Charles", age:33}, 
				    {name:"Connor Morgan", age:50}, 
				    {name:"Everett Frank", age:16}  
				])));
		}
		
		public function test_sequenceEqual():void
		{
			var data:IEnumerable = new ASLinq();
			trace("assertTrue",data.sequenceEqual(new ASLinq()));
			data = new ASLinq([1, 2, "3"]);
			trace("assertTrue",data.sequenceEqual(new ASLinq([1, 2, "3"])));
			trace("assertFalse",data.sequenceEqual(new ASLinq([1, "3"])));
			trace("assertFalse",data.sequenceEqual(new ASLinq([1, 4, "3"])));
			trace("assertFalse",data.sequenceEqual(new ASLinq([1, 2, 3])));
			trace("assertTrue",people.sequenceEqual(new ASLinq([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
			trace("assertFalse",people.sequenceEqual(new ASLinq([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:"16", canCode:true} 
			])));
			trace("assertFalse",people.sequenceEqual(new ASLinq([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:17, canCode:true} 
			])));
			trace("assertFalse",people.sequenceEqual(new ASLinq([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
			trace("assertFalse",people.sequenceEqual(new ASLinq([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
			trace("assertFalse",people.sequenceEqual(new ASLinq([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50},
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			])));
		}
		
		public function test_single():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:Boolean; 
			try {
				data.single();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			trace("assertFalse",result);
			data = new ASLinq();
			try {
				data.single();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			trace("assertFalse",result);
			data = new ASLinq([1]);
			try {
				data.single();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			trace("assertTrue",result);
		}
		
		public function test_singleOrDefault():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var result:Boolean; 
			try {
				data.singleOrDefault();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			trace("assertFalse",result);
			data = new ASLinq();
			try {
				data.singleOrDefault();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			trace("assertTrue",result);
			data = new ASLinq([1]);
			try {
				data.singleOrDefault();
				result = true;
			} catch (err:Error) {
				result = false;
			}
			trace("assertTrue",result);
		}
		
		public function test_skip():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			trace("assertTrue",data.skip(3).sequenceEqual(new ASLinq([4, 5])));
			trace("assertEquals",data.skip(10).count(), 0);
			trace("assertTrue",people.skip(3).sequenceEqual(new ASLinq([
				{name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true}	
			])));
			trace("assertEquals",people.skip(10).count(), 0);
			trace("assertEquals",(new ASLinq()).skip(10).count(), 0);
		}
		
		public function test_skipWhile():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			trace("assertTrue",data.skipWhile(function(x){return x<4}).sequenceEqual(new ASLinq([4, 5])));
			trace("assertEquals",(new ASLinq()).skipWhile(function(x){return x < 4}).count(), 0);
			var result:IEnumerable = customers.skipWhile(function(x) {
				return x.name != "Gauwin";
			});
			trace("assertTrue",result.sequenceEqual(new ASLinq([
			    {id:3, name:"Gauwin"}, 
			    {id:4, name:"Deane"}, 
			    {id:5, name:"Zeeman"}
		    ])));
		}
		
		public function test_sum():void
		{
			var data:IEnumerable = new ASLinq([-1, 1, 2, 3, 4, 5]);
			var result:int = data.sum(function(x) {return x;});
			trace("assertEquals",result, 14);
			var result2:String = data.sum(function(x:int):String {return x.toString();});
			trace("assertEquals",result2, "-112345");
		}
		
		public function test_take():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			trace("assertTrue",data.take(3).sequenceEqual(new ASLinq([1, 2, 3])));
			trace("assertEquals",data.take(10).count(), 5);
			trace("assertTrue",people.take(3).sequenceEqual(new ASLinq([
				{name:"Allen Frances", age:11, canCode:false}, 
		    	{name:"Burke Madison", age:50, canCode:true}, 
		    	{name:"David Charles", age:33, canCode:true}	
			])));
			trace("assertEquals",people.take(10).count(), 5);
			trace("assertEquals",(new ASLinq()).take(10).count(), 0);
		}
		
		public function test_takeWhile():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			trace("assertTrue",data.takeWhile(function(x){return x<4}).sequenceEqual(new ASLinq([1, 2, 3])));
			trace("assertEquals",(new ASLinq()).takeWhile(function(x){return x<4}).count(), 0);
			var result:IEnumerable = customers.takeWhile(function(x) {
				return x.name != "Gauwin";
			});
			trace("assertTrue",result.sequenceEqual(new ASLinq([
			    {id:1, name:"Gotts"}, 
		    	{id:2, name:"Valdes"} 
		    ])));
		}
		
		public function test_thenBy():void
		{
			var result:IEnumerable = people.orderBy("canCode").thenBy("name");
			trace("assertTrue",result.sequenceEqual(new ASLinq([
				{name:"Allen Frances", age:11, canCode:false}, 
		    	{name:"Connor Morgan", age:50, canCode:false},
		    	{name:"Burke Madison", age:50, canCode:true}, 
		    	{name:"David Charles", age:33, canCode:true}, 
		    	{name:"Everett Frank", age:16, canCode:true} 	
			])));
			var result2:IEnumerable = people.orderBy("canCode").thenBy(
				function(x) { return x.name; },
				function(x, y) { return x > y; }
			);
			trace("assertTrue",result.sequenceEqual(result2));
		}
		
		public function test_thenByDescending():void
		{
			var result:IEnumerable = people.orderBy("canCode").thenByDescending("name");
			trace("assertTrue",result.sequenceEqual(new ASLinq([
				{name:"Connor Morgan", age:50, canCode:false},
				{name:"Allen Frances", age:11, canCode:false}, 
		    	{name:"Everett Frank", age:16, canCode:true}, 
		    	{name:"David Charles", age:33, canCode:true}, 
		    	{name:"Burke Madison", age:50, canCode:true}	
			])));
			var result2:IEnumerable = people.orderBy("canCode").thenByDescending(
				function(x) { return x.name; }
			);
			trace("assertTrue",result.sequenceEqual(result2));
		}
		
		public function test_toArray():void
		{
			var data:IEnumerable = new ASLinq([1, 2, 3]);
			var result:Array = data.toArray();
			trace("assertEquals",result.length, 3);
			trace("assertEquals",result[0], 1);
			trace("assertEquals",result[1], 2);
			trace("assertEquals",result[2], 3);
		}
		
		public function test_toDictionary():void
		{
			var i:uint = 0;
			var result:Dictionary = people.toDictionary(
				function(x) {return x.name;},
				function(x) {return (x.name as String).length + i++;},
				function(x, y) {return x.toUpperCase() == y.toUpperCase()}
			);
			trace("assertEquals",result["Allen Frances"], 13);	 
			trace("assertEquals",result["Burke Madison"], 14);
			trace("assertEquals",result["David Charles"], 15);
			trace("assertEquals",result["Connor Morgan"], 16);
			trace("assertEquals",result["Everett Frank"], 17);
		}
		
		public function test_toASLinq():void
		{
			var data:IEnumerable = new ASLinq([ 
			    {name:"Allen Frances", age:11, canCode:false}, 
			    {name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Connor Morgan", age:50, canCode:false}, 
			    {name:"Everett Frank", age:16, canCode:true} 
			]);
			var result:IEnumerable = data.toASLinq();
			trace("assertTrue",result.sequenceEqual(people)); 
		}
		
		public function test_union():void
		{
			var data1:IEnumerable = new ASLinq([1, 2, 3, 4, 5]);
			var data2:IEnumerable = new ASLinq([4, 5, 6, 7]);
			var result:String = data1.union(data2).print(null, true, "", false);
			trace("assertEquals",result, "1\n2\n3\n4\n5\n6\n7\n");
			result = data1.union(new ASLinq()).print(null, true, "", false);
			trace("assertEquals",result, "1\n2\n3\n4\n5\n");
			result = (new ASLinq()).union(data2).print(null, true, "", false);
			trace("assertEquals",result, "4\n5\n6\n7\n");
			var data3:IEnumerable = new ASLinq([
				{id:3, name:"Gauwin"}, 
		    	{id:4, name:"Deane"}, 
		    	{id:6, name:"Reeman"}
			]);
			var result2:IEnumerable = customers.union(data3);
			trace("assertTrue",result2.sequenceEqual(new ASLinq([
				{id:1, name:"Gotts"}, 
			    {id:2, name:"Valdes"}, 
			    {id:3, name:"Gauwin"}, 
			    {id:4, name:"Deane"}, 
			    {id:5, name:"Zeeman"},
		    	{id:6, name:"Reeman"}
			])));
			var data4:IEnumerable = new ASLinq([3, 4, 6]);
			result2 = customers.union(data4, function(x, y) { return x.id == y; });
			trace("assertTrue",result2.sequenceEqual(new ASLinq([
				{id:1, name:"Gotts"}, 
			    {id:2, name:"Valdes"}, 
			    {id:3, name:"Gauwin"}, 
			    {id:4, name:"Deane"}, 
			    {id:5, name:"Zeeman"},
		    	6
			])));
		}
		
		public function test_where():void
		{
			var data:IEnumerable = new ASLinq([6, 8, 3, 4, 7]);
			var result:IEnumerable = data.where(
				function(x) {return x > 5;}
			);
			trace("assertTrue",result.sequenceEqual(new ASLinq([6, 8, 7])));
			result = people.where(function(x) { return x.name == "Burke Madison"; });
			trace("assertTrue",result.sequenceEqual(new ASLinq([
				{name:"Burke Madison", age:50, canCode:true}, 
			    {name:"David Charles", age:33, canCode:true}, 
			    {name:"Everett Frank", age:16, canCode:true}
			])));
			result = (new ASLinq()).where(function(x) { return x.canCode == true; });
			trace("assertTrue",result.sequenceEqual(new ASLinq()));
		}
		
	}
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
