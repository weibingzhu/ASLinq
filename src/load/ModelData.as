package load
{
	import com.manager.loaderManager.LoaderManager;
	import com.manager.loaderManager.ResLoader;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class ModelData
	{
		public function ModelData()
		{
			var loader:ResLoader = LoaderManager.load("C:/Users/Administrator/Desktop/2016新起点/Config.data",complete);
		}
		
		private function complete(loader:ResLoader, data:Object):void
		{
			var byte:ByteArray = data as ByteArray;
			byte.uncompress();
			var dic:Dictionary = new Dictionary();
			byte.position = 0;
			var i:int;
			var name:String;
			while (byte.bytesAvailable)
			{
				if (i % 2 == 0)
					name = byte.readObject();
				else
					dic[name] = byte.readObject();
				i++;
			}
			var obj:  Object = dic['UiUnlock'];
			var  test:IEnumerable = new FinqObj(obj);
			
			var result : IEnumerable =test.where(function(x){return x.id == 10});
			var ave:int = test.average(function(x) {return x.id;});
			var result : IEnumerable = test.orderBy("openLv");
			var result : IEnumerable = test.where(function(x) { return x.openLv == 1; });
			
		}
	}
}