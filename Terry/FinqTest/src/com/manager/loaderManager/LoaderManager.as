package com.manager.loaderManager
{
	import flash.display.BitmapData;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author tyw
	 */
	public class LoaderManager
	{
		/**加载完成缓存*/
		private static const LOADED_CACHE:Dictionary = new Dictionary();
		/**预加载容器*/
		private static const WAIT_LOAD_CACHE:Dictionary = new Dictionary();
		/**未加载缓存*/
		private static const WAIT_LOAD_LIST:Vector.<ResLoader> = new Vector.<ResLoader>();
		/**优先加载资源*/
		private static const PRIORITY_LOAD_LIST:Vector.<ResLoader> = new Vector.<ResLoader>();
		/**当前加载列表*/
		private static const LOADING_LIST:Vector.<ResLoader> = new Vector.<ResLoader>();
		/**组加载列表*/
		private static var tempLoadList:Vector.<ResLoader>;
		/**最大同时加载数*/
		public static var MAX_LOADING_NUM:int = 1;
		/**曾经加载完成的资源*/
		public static const OLD_LOADED_LIST:Array = [];
		
		private static var LOADED_NUM:int = 0;
		
		/**
		 * 加载器管理
		 */
		public function LoaderManager()
		{
		
		}
		
		/**
		 * 加载资源
		 * @param	url 加载路径
		 * @param	onComplete 加载完成回调
		 * @param	onProgress 加载进度回调
		 * @param	reloading 是否重新加载(true:每次都重新加载,不存缓存池,加载完成后会马上释放掉,false:每次读取缓存);
		 * @param	domain 加载域
		 * @param	isPriority 是否优先加载
		 * @param	isList 是否组加载
		 * @param	showLoading 是否显示加载进度面板
		 * @param	canAutoDispose 能否自动释放资源
		 * @return
		 */
		public static function load(url:String, onComplete:Function = null, onProgress:Function = null, reloading:Boolean = false, domain:ApplicationDomain = null, isPriority:Boolean = false, isList:Boolean = false, showLoading:Boolean = false, canAutoDispose:Boolean = true, autoLoad:Boolean = true):ResLoader
		{
			if (ResLoader.onUnLoad == null)
			{
				ResLoader.onUnLoad = deleteLoader;
			}
			if (url == null || url == "")
				return null;
			var loader:ResLoader;
			if (reloading)
			{
				loader = new ResLoader(url, new Vector.<Function>(), onProgress, reloading, domain, isList, showLoading, canAutoDispose);
				loader.addCompleteBack(loadComplete);
				loader.addCompleteBack(onComplete);
				if (OLD_LOADED_LIST.indexOf(url) != -1)
				{
					loader.initLoad();
				}
				else
				{
					if (isPriority)
						PRIORITY_LOAD_LIST.push(loader);
					else
						WAIT_LOAD_LIST.push(loader);
					if (autoLoad)
						loadNext();
				}
			}
			else
			{
				if (LOADED_CACHE[url])
				{
					loader = LOADED_CACHE[url];
					//Debug.ins.outPut("直接完成回调：", url);
					if (onComplete is Function)
						onComplete(loader, loader.data is BitmapData ? loader.data.clone() : loader.data);
				}
				else
				{
					loader = hasLoadingList(url);
					if (loader)
					{
						loader.addCompleteBack(onComplete);
					}
					else if (WAIT_LOAD_CACHE[url])
					{
						loader = WAIT_LOAD_CACHE[url];
						loader.addCompleteBack(onComplete);
						if (autoLoad)
							loadNext();
					}
					else
					{
						loader = new ResLoader(url, new Vector.<Function>(), onProgress, reloading, domain, isList, showLoading, canAutoDispose);
						loader.addCompleteBack(loadComplete);
						loader.addCompleteBack(onComplete);
						if (OLD_LOADED_LIST.indexOf(url) != -1)
						{
							if (autoLoad)
								loader.initLoad();
						}
						else
						{
							if (isPriority)
								PRIORITY_LOAD_LIST.push(loader);
							else
								WAIT_LOAD_LIST.push(loader);
							WAIT_LOAD_CACHE[url] = loader;
							if (autoLoad)
								loadNext();
						}
					}
				}
			}
			return loader;
		}
		
		/**
		 * 加载完成
		 * @param	loader
		 */
		static private function loadComplete(loader:ResLoader, data:*):void
		{
			var index:int;
			if (tempLoadList && loader.isList)
			{
				index = tempLoadList.indexOf(loader);
				tempLoadList.splice(index, 1);
				if (tempLoadList.length == 0)
					tempLoadList = null;
			}
			if (OLD_LOADED_LIST.indexOf(loader.url) == -1)
			{
				OLD_LOADED_LIST[OLD_LOADED_LIST.length] = loader.url;
			}
			index = LOADING_LIST.indexOf(loader);
			if (index != -1)
			{
				LOADING_LIST.splice(index, 1);
			}
			if (!loader.reloading && loader.loadState == ResLoader.LOAD_COMPLETE)
			{
				LOADED_CACHE[loader.url] = loader;
				LOADED_NUM++;
			}
			loadNext();
		}
		
		/**
		 * 加载下一项
		 */
		static private function loadNext():void
		{
			if (LOADING_LIST.length < MAX_LOADING_NUM)
			{
				var loader:ResLoader = PRIORITY_LOAD_LIST.length > 0 ? PRIORITY_LOAD_LIST.shift() : (WAIT_LOAD_LIST.length > 0 ? WAIT_LOAD_LIST.shift() : null);
				if (loader)
				{
					if (loader.url && loader.url != "")
					{
						delete WAIT_LOAD_CACHE[loader.url];
						LOADING_LIST.push(loader);
						loader.initLoad();
					}
					else
						loadNext();
				}
			}
		}
		
		/**
		 * 是否在加载中列表
		 * @param	url
		 * @return
		 */
		static private function hasLoadingList(url:String):ResLoader
		{
			for (var i:int = 0, j:int = LOADING_LIST.length; i < j; i++)
			{
				if (LOADING_LIST[i].url == url)
					return LOADING_LIST[i];
			}
			return null;
		}
		
		/**
		 * 释放
		 * @param	url
		 */
		public static function unload(url:String):void
		{
			if (LOADED_CACHE[url])
			{
				(LOADED_CACHE[url] as ResLoader).unload();
			}
			else
			{
				if (WAIT_LOAD_CACHE[url])
				{
					(WAIT_LOAD_CACHE[url] as ResLoader).unload();
				}
				else
				{
					var index:int = findLoader(url, LOADING_LIST);
					if (index != -1)
					{
						LOADING_LIST[index].unload();
						LOADING_LIST.splice(index, 1);
						LOADED_NUM--;
					}
				}
			}
		}
		
		/**
		 * 释放资源
		 * @param url 释放资源路径
		 */
		public static function deleteLoader(url:String):void
		{
			if (LOADED_CACHE[url])
			{
				delete LOADED_CACHE[url];
				LOADED_NUM--;
			}
			else
			{
				var index:int;
				if (WAIT_LOAD_CACHE[url])
				{
					var loader:ResLoader = WAIT_LOAD_CACHE[url];
					delete WAIT_LOAD_CACHE[url];
					index = WAIT_LOAD_LIST.indexOf(loader);
					if (index != -1)
					{
						WAIT_LOAD_LIST.splice(index, 1);
					}
					else
					{
						index = PRIORITY_LOAD_LIST.indexOf(loader);
						if (index != -1)
						{
							PRIORITY_LOAD_LIST.splice(index, 1);
						}
					}
				}
				else
				{
					index = findLoader(url, LOADING_LIST);
					if (index != -1)
					{
						LOADING_LIST.splice(index, 1);
					}
				}
			}
		}
		
		/**
		 * 查找loader
		 * @param	url
		 * @param	list
		 * @return
		 */
		private static function findLoader(url:String, list:Vector.<ResLoader>):int
		{
			for (var i:int = 0, j:int = list.length; i < j; i++)
			{
				if (list[i].url == url)
					return i;
			}
			return -1;
		}
		
		/**
		 * 自动施放所有资源(需要施放的)
		 */
		public static function autoUnloadAll():void
		{
			for each (var loader:ResLoader in LOADED_CACHE)
			{
				if (loader.canAutoDispose)
				{
					loader.unload();
				}
			}
		}
		
		public static function getResLoader(url:String):ResLoader
		{
			return LOADED_CACHE[url];
		}
		
		/**
		 * 加载图片
		 * @param	url
		 * @param	onComplete
		 * @param	reloading
		 * @param	canAutoDispose 能否自动释放
		 */
		public static function loadImg(url:String, onComplete:Function = null, reloading:Boolean = false, canAutoDispose:Boolean = true, onProgress:Function = null):ResLoader
		{
			return load(url, onComplete, onProgress, reloading, null, false, false, false, canAutoDispose);
		}
		
		/**
		 * 只有当加载单一模块文件时才有效
		 */
		public static function loadList(list:Array, onComplete:Function, onProgress:Function):Vector.<ResLoader>
		{
			tempLoadList = new Vector.<ResLoader>();
			var resLoader:ResLoader;
			var func:Function;
			for (var i:int = 0, j:int = list.length; i < j; i++)
			{
				func = (i == (j - 1) ? onComplete : null);
				//Debug.ins.outPut(i, j, list[i], String(func is Function));
				resLoader = load(list[i], i == j - 1 ? onComplete : null, onProgress, false, null, true, true, false, false, false);
				resLoader.setIndex(i, j);
				tempLoadList.push(resLoader);
			}
			loadNext();
			return tempLoadList.concat();
		}
	
	}

}