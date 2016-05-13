package com.manager.loaderManager 
{
	import com.util.CommonTool;
	import flash.system.ApplicationDomain;
	/**
	 * ...
	 * @author Neil
	 */
	public class LoaderInfo 
	{
		/**是否需要重新加载*/
		public var reloading:Boolean;
		// 地址
		public var strUrl : String;
		
		// 回调函数
		public var arrCallBack : Vector.<Function>;
		
		// 加载类型
		public var strType : String;
		
		// 文件名称
		public var strName : String;
		
		// 优先级
		public var iLevel : int;
		
		// 是否需要保存
		public var isNeedSave : Boolean;
		
		//
		public var appDomain : ApplicationDomain;
		
		// 是否后台加载
		public var isBackgroundLoad : Boolean;
		
		public function LoaderInfo(url:String, callBack:* = null, level:int = 0, needSave:Boolean = true, backgroundLoad:Boolean = true,  type:String = null, name:String = '', domain:ApplicationDomain = null, reloading:Boolean = false)
		{
			strUrl = url;
			iLevel = level;
			isNeedSave = needSave;
			isBackgroundLoad = backgroundLoad;
			strType = type;
			strName = name;
			appDomain = domain;
			this.reloading = reloading;
			
			if (callBack is Function)
				arrCallBack = new <Function>[callBack];
			else if (callBack is Array)
			{
				arrCallBack = new Vector.<Function>;
				for (var i:int = 0; i < callBack; i++) 
				{
					arrCallBack.push(callBack[i]);
				}
				arrCallBack = null;
			}
			else if (callBack is Vector.<Function>)
			{
				arrCallBack = CommonTool.cloneArray(callBack) as Vector.<Function>;
				callBack = null;
			}
		}
		
		public function callBack(data:*):void
		{
			if (!arrCallBack || arrCallBack.length == 0) return ;
			for (var i:int = 0; i < arrCallBack.length; i++) 
			{
				arrCallBack[i].apply(null, [null, data]);
			}
		}
		
	}

}