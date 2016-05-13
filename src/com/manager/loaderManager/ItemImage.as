package com.manager.loaderManager
{
	import com.util.DefinitionManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author tyw
	 * @time 2013/10/25 11:47:30
	 */
	public class ItemImage extends Image
	{
		
		private var _hasBg:Boolean;
		private var _bg:Bitmap;
		private var _bgName:String = "";
		private var _itemSize:uint = 0;
		public function ItemImage(url:String, onComplete:Function = null, hasBg:Boolean = false,bgName:String = "ItemBox",itemSize:uint = 0)
		{
			_hasBg = hasBg;
			_bgName = bgName;
			_itemSize = itemSize;
			super(url, onComplete);
		}
		
		override protected function init(reloading:Boolean):void
		{
			if (_hasBg)
			{
				var cls:BitmapData;
				if(_bgName == "itemBox")
					cls = new (DefinitionManager.getDefinition("ItemBox") as Class)();
				else if(_bgName == "eItemBox")
					cls = new (DefinitionManager.getDefinition("EItemBox") as Class)();
				else if(_bgName == "skillBox")
					cls = new (DefinitionManager.getDefinition("TIPSkillBox") as Class)();
				
				_bg = new Bitmap(cls);
				addChild(_bg);
			}
			super.init(reloading);
		}
		
		override protected function loadComplete(loader:ResLoader, data:Object):void
		{
			if (data is BitmapData)
			{
				var bmp:Bitmap = new Bitmap(data as BitmapData);
				if(_itemSize != 0){
					bmp.width = bmp.height = _itemSize;
				}
				addChild(bmp);
				if (_hasBg)
				{
					bmp.x = (_bg.width - bmp.width) * 0.5;
					bmp.y = (_bg.height - bmp.height) * 0.5;
				}
				if (_onComplete is Function)
				{
					_onComplete(this);
				}
			}
			else
			{
				super.loadComplete(loader, data);
			}
		}
	}

}