package com.manager.loaderManager
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	//import tool.Debug;
	
	/**
	 * 加载器
	 * @author tyw
	 */
	public class ResLoader extends EventDispatcher
	{
		static public var onUnLoad:Function;
		
		static public var VERSION:String = "1.1";
		
		static public const RESTYPE_DISPLAYER:int = 0;
		static public const RESTYPE_TXT:int = 1;
		static public const RESTYPE_DATA:int = 2;
		
		static public const NOT_LOADED:int = 0;
		static public const LOADING:int = 1;
		static public const LOAD_COMPLETE:int = 2;
		static public const LOAD_ERROR:int = 3;
		/**文件名*/
		private var _name:String;
		/**路径*/
		private var _url:String;
		/**0:未加载 1:加载中 2:加载完成 3:加载错误*/
		private var _loadState:int;
		/**0:显示对象加载 1:文本加载 2:二进制加载*/
		private var _resType:int;
		/**加载域*/
		private var _domain:ApplicationDomain;
		/**加载器*/
		private var _loader:*;
		/**加载数据 (MovieClip,BitmapData,字符串,二进制文件)*/
		private var _data:*;
		/**加载完成回调*/
		private var _onComplete:Vector.<Function>;
		/**加载进度回调*/
		private var _onProgress:Function;
		/**重新加载*/
		private var _reloading:Boolean;
		/**是否列表加载*/
		private var _isList:Boolean;
		/**是否显示加载面板*/
		private var _showLoading:Boolean;
		private var _index:int = 1;
		private var _count:int = 1;
		private var _suffix:String;
		/**能否自动释放*/
		private var _canAutoDispose:Boolean;
		/**加载次数*/
		private var loadNum:int;
		
		/**
		 * 加载器
		 * @param	url
		 * @param	onComplete
		 * @param	onProgress
		 * @param	domain
		 */
		public function ResLoader(url:String, onComplete:Vector.<Function>, onProgress:Function, reloading:Boolean, domain:ApplicationDomain, isList:Boolean, showLoading:Boolean,canAutoDispose:Boolean)
		{
			_url = url;
			_domain = domain ? domain : ApplicationDomain.currentDomain;
			_onComplete = onComplete;
			_onProgress = onProgress;
			_reloading = reloading;
			_isList = isList;
			_showLoading = showLoading;
			_canAutoDispose = canAutoDispose;
		}
		
		/**
		 * 开始加载
		 */
		public function initLoad():void
		{
			//Debug.ins.outPut(_index, "加载资源：", _url);
			if (_url == null || _url == "")
			{
				execComplete(true);
			}
			loadNum++;
			parseURL(_url);
			switch (_resType)
			{
				case RESTYPE_DISPLAYER: 
					_loader = new Loader();
					addLoaderEvent(_loader.contentLoaderInfo);
					(_loader as Loader).load(new URLRequest(_url + "?v=" + VERSION), new LoaderContext(false, _domain));
					break;
				case RESTYPE_TXT: 
					_loader = new URLLoader();
					addLoaderEvent(_loader);
					(_loader as URLLoader).load(new URLRequest(url));
					break;
				case RESTYPE_DATA: 
					_loader = new URLLoader();
					(_loader as URLLoader).dataFormat = URLLoaderDataFormat.BINARY;
					addLoaderEvent(_loader);
					(_loader as URLLoader).load(new URLRequest(url + "?v=" + VERSION));
					break;
				default: 
			}
		}
		
		/**
		 * 释放资源
		 */
		public function unload():void
		{
			if (_loader)
			{
				if (_loadState != NOT_LOADED)
				{
					switch (_resType)
					{
						case RESTYPE_DISPLAYER: 
							if (_loadState == LOADING)
								_loader.close();
							(_loader as Loader).unloadAndStop(false);
							break;
						case RESTYPE_TXT: 
						case RESTYPE_DATA: 
							(_loader as URLLoader).close();
							break;
						default: 
					}
					_loader = null;
				}
			}
			if (_data is BitmapData)
			{
				(_data as BitmapData).dispose();
			}
			_data = null;
			_domain = null;
			_onComplete = null;
			_onProgress = null;
			onUnLoad(this.url);
			_url = null;
		}
		
		/**
		 * 添加回调方法
		 * @param	fuc
		 */
		public function addCompleteBack(fuc:Function):void
		{
			if (fuc is Function && _onComplete && _onComplete.indexOf(fuc) == -1)
			{
				_onComplete.push(fuc);
			}
			//Debug.ins.outPut("初始化加载资源：", url, _onComplete && _onComplete.length > 1?"true":"false");
		}
		
		/**
		 * 获取域名下的类
		 * @param	name
		 * @return
		 */
		public function getDefinition(name:String):Class
		{
			return _domain.getDefinition(name) as Class;
		}
		
		public function setIndex(index:int, count:int):void
		{
			_index = index;
			_count = count;
		}
		
		/**
		 * 解析UI
		 * @param	url
		 */
		private function parseURL(url:String):void
		{
			if(url == null)
				return ;
			var tempArr:Array = url.split("/");
			tempArr = tempArr[tempArr.length - 1].split(".");
			_name = tempArr[0];
			_suffix = tempArr[tempArr.length - 1].toLowerCase();
			switch (_suffix)
			{
				case "zip": 
				case "mp3": 
				case "bg": 
				case "atf": 
				case "data": 
					_resType = RESTYPE_DATA;
					break;
				case "xml": 
				case "txt": 
				case "html": 
				case "htm": 
				case "config": 
				case "json": 
					_resType = RESTYPE_TXT;
					break;
				case "swf": 
				case "jpg": 
				case "bmp": 
				case "gif": 
				case "png": 
				default: 
					_resType = RESTYPE_DISPLAYER;
			}
		}
		
		/**
		 * 添加加载事件
		 * @param	target
		 */
		private function addLoaderEvent(target:IEventDispatcher):void
		{
			target.addEventListener(Event.COMPLETE, loadComplete);
			target.addEventListener(ProgressEvent.PROGRESS, loadProgress);
			target.addEventListener(IOErrorEvent.IO_ERROR, loadIOError);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadSecurityError);
			target.addEventListener(Event.INIT, loadInitData);
		}
		
		private function loadInitData(e:Event):void 
		{
			_loadState = LOADING;
		}
		
		/**
		 * 移除加载事件
		 * @param	target
		 */
		private function removeLoaderEvent(target:IEventDispatcher):void
		{
			target.removeEventListener(Event.COMPLETE, loadComplete);
			target.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			target.removeEventListener(IOErrorEvent.IO_ERROR, loadIOError);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadSecurityError);
			target.removeEventListener(Event.INIT, loadInitData);
		}
		
		/**
		 * 加载完成
		 * @param	e
		 */
		private function loadComplete(e:Event):void
		{
			removeLoaderEvent(e.currentTarget as EventDispatcher);
			_onProgress = null;
			if (_loader == null)
			{
				return;
			}
			switch (_resType)
			{
				case RESTYPE_DISPLAYER: 
					if ((_loader as Loader).content is Bitmap)
						_data = ((_loader as Loader).content as Bitmap).bitmapData;
					else if ((_loader as Loader).content is MovieClip)
						_data = (_loader as Loader).content;
					break;
				case RESTYPE_TXT: 
				case RESTYPE_DATA: 
					_data = (_loader as URLLoader).data;
					break;
				default: 
			}
			_loadState = LOAD_COMPLETE;
			execComplete();
			//Debug.ins.outPut("加载资源完成：", _url);
		}
		
		/**
		 * 执行方法回调
		 */
		private function execComplete(error:Boolean = false):void
		{
			if (_onComplete)
			{
				var fuc:Function;
				if (error)
				{
					_data = getDefaultData(_suffix);
					while (_onComplete&&_onComplete.length)
					{
						fuc = _onComplete.shift();
						fuc(this, _data is BitmapData ? _data.clone() : _data);
					}
					unload();
				}
				else
				{
					while (_onComplete && _onComplete.length)
					{
						fuc = _onComplete.shift();
						fuc(this, _data is BitmapData ? _data.clone() : _data);
					}
					_onComplete = null;
				}
			}
		}
		
		private static function getDefaultData(suffix:String):Object
		{
			switch (suffix)
			{
				case "zip": 
				case "mp3": 
				case "bg": 
				case "atf": 
				case "data": 
					return null;
				case "xml": 
				case "txt": 
				case "html": 
				case "htm": 
				case "config": 
				case "json": 
					return "";
				case "swf": 
					return null;
				case "jpg": 
				case "bmp": 
				case "gif": 
				case "png": 
					return new BitmapData(1, 1, true, 0);
				default: 
					return null;
			}
		}
		
		/**
		 * 加载资源进度
		 * @param	e
		 */
		private function loadProgress(e:ProgressEvent):void
		{
			if (_onProgress is Function)
			{
				_onProgress(_index, _count, e.bytesLoaded / e.bytesTotal);
			}
		}
		
		/**
		 * 加载路径IO错误
		 * @param	e
		 */
		private function loadIOError(e:IOErrorEvent):void
		{
			removeLoaderEvent(e.currentTarget as EventDispatcher);
			//Debug.ins.outPut("资源加载路径错误", _url);
			
			if (loadNum < 3)
			{
				initLoad();
				stopLoad();
			}
			else
			{
				_loadState = LOAD_ERROR;
				execComplete(true);
			}
		}
		
		private function stopLoad():void
		{
			if (_loader)
			{
				if (_loadState != NOT_LOADED)
				{
					switch (_resType)
					{
						case RESTYPE_DISPLAYER: 
							if (_loadState == LOADING)
								_loader.close();
							(_loader as Loader).unloadAndStop(false);
							if((_loader as Loader).contentLoaderInfo)
								removeLoaderEvent((_loader as Loader).contentLoaderInfo);
							break;
						case RESTYPE_TXT: 
						case RESTYPE_DATA:
							(_loader as URLLoader).close();
							removeLoaderEvent(_loader as URLLoader);
							break;
						default: 
					}
					_loader = null;
				}
			}
		}
		
		/**
		 * 加载域错误
		 * @param	e
		 */
		private function loadSecurityError(e:SecurityErrorEvent):void
		{
			removeLoaderEvent(e.currentTarget as EventDispatcher);
			//Debug.ins.outPut("资源加载域错误", e.text);
			if (loadNum < 3)
			{
				initLoad();
				stopLoad();
			}
			else
			{
				_loadState = LOAD_ERROR;
				execComplete(true);
			}
		}
		
		/**
		 * 加载路径
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * 加载资源类型
		 */
		public function get resType():int
		{
			return _resType;
		}
		
		/**
		 * 加载状态
		 */
		public function get loadState():int
		{
			return _loadState;
		}
		
		/**
		 * 加载完成数据(MovieClip,BitmapData,字符串,二进制文件);
		 */
		public function get data():*
		{
			return _data;
		}
		
		/**
		 * 加载域
		 */
		public function get domain():ApplicationDomain
		{
			return _domain;
		}
		
		/**
		 * 资源是否重新加载
		 */
		public function get reloading():Boolean
		{
			return _reloading;
		}
		
		public function get loader():*
		{
			return _loader;
		}
		
		public function get isList():Boolean
		{
			return _isList;
		}
		
		public function get name():String 
		{
			return _name;
		}
		
		/**
		 * 能否自动释放
		 */
		public function get canAutoDispose():Boolean 
		{
			return _canAutoDispose;
		}
		
		public function set canAutoDispose(value:Boolean):void 
		{
			_canAutoDispose = value;
		}
	}

}