package com.manager.loaderManager
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 图片.影片加载类
	 * @author tyw
	 */
	public class Image extends Sprite
	{
		private var _data:Object;
		private var _addFrameRemove:Boolean;
		private var _autoDispose:Boolean;
		protected var _onComplete:Function;
		protected var _url:String;
		
		/**
		 * 图片.影片加载类
		 * @param	url
		 * @param	onComplete
		 */
		public function Image(url:String, onComplete:Function = null, reloading:Boolean = false, autoDispose:Boolean = true)
		{
			_onComplete = onComplete;
			_url = url;
			_autoDispose = autoDispose;
			init(reloading);
		}
		
		/**
		 * 初始化加载
		 */
		protected function init(reloading:Boolean):void
		{
			LoaderManager.load(_url, loadComplete, null, reloading);
		}
		
		public function addEndFrameRemove():void
		{
			if (_data && _data is MovieClip)
			{
				_data.addFrameScript(_data.totalFrames - 1, removeSelf);
			}
			else
			{
				_addFrameRemove = true;
			}
		}
		
		/**
		 * 加载完成
		 * @param	e
		 * @param	data
		 */
		protected function loadComplete(loader:ResLoader, data:Object):void
		{
			_data = data;
			if (data is BitmapData)
			{
				var bmp:Bitmap = new Bitmap(data as BitmapData);
				bmp.smoothing = true;
				addChild(bmp);
			}
			else if (data is DisplayObject)
			{
				addChild(data as DisplayObject);
				if (data is MovieClip)
				{
					if (_addFrameRemove)
					{
						_data.addFrameScript(_data.totalFrames - 1, removeSelf);
					}
					data.gotoAndPlay(1);
				}
			}
			if (_onComplete is Function)
			{
				_onComplete(this);
			}
			//if(_autoDispose)
				this.addEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
		}
		
		private function removeFromStage(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
			if(_autoDispose)
				dispose();
			else
			{
				_data is MovieClip?_data.stop():null;
				this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			}
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
			if (_data is MovieClip)
				_data.play();
		}
		
		public function dispose():void
		{
			if (this.hasEventListener(Event.REMOVED_FROM_STAGE))
				this.removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
			if (this.hasEventListener(Event.ADDED_TO_STAGE))
				this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			while (this.numChildren)
			{
				this.removeChildAt(0);
			}
			if (_data is MovieClip)
				_data.stop();
			else if (_data is BitmapData)
				_data.dispose();
			LoaderManager.unload(_url);
			_data = null;
			_onComplete = null;
			_url = null;
		}
		
		private function removeSelf():void
		{
			_data.addFrameScript(_data.totalFrames - 1, null);
			if (this.parent)
				this.parent.removeChild(this);
			else
			{
				removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
				dispose();
			}
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function get url():String
		{
			return _url;
		}
	
	}

}