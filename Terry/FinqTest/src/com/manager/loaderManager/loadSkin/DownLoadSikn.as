package com.manager.loaderManager.loadSkin 
{
	import com.manager.loaderManager.LoaderInfo;
	import com.util.DefinitionManager;
	import face.IDownloadSkin;
	import flash.display.MovieClip;
	import flash.events.ProgressEvent;
	/**
	 * ...
	 * @author 
	 */
	public class DownLoadSikn implements IDownloadSkin
	{
		protected var _mcSkin : MovieClip;
		
		protected var _arrTotalRes: Vector.<LoaderInfo>;
		
		protected var _arrLoad : Vector.<String>;
		
		public function DownLoadSikn() 
		{
			
		}
		
		public function setSkin(strSkinClass:String = '', skin:MovieClip = null):void
		{
			if (strSkinClass != null && strSkinClass != "")
			{
				_mcSkin = (DefinitionManager.getDefinitionInstance(strSkinClass) as MovieClip);
			}
			else if (_mcSkin != null)
			{
				_mcSkin = skin;
			}
			if(!_mcSkin)
				_mcSkin = DefinitionManager.getDefinitionInstance('DefaultDownLoadSkin_View') as MovieClip;
		}
		
		public function setTotalRes(arrRes:Vector.<LoaderInfo>):void
		{
			_arrTotalRes = arrRes;
		}
		
		/* INTERFACE face.IDownloadSkin */
		
		public function showLoadSkin(...res):void 
		{
			if (!_mcSkin)
				setSkin();
			_mcSkin.mcLoadPlanned.width = 0;
			//LayerManager.ins.addToCenter(LayerConfig.TOP, _mcSkin);
		}
		
		public function hideLoadSkin(...res):void 
		{
			//LayerManager.ins.removeFromLayer(LayerConfig.TOP, _mcSkin);
			_mcSkin = null;
		}
		
		public function onDownloadRrogress(e:ProgressEvent, ...res):void 
		{
			var iCurLoad : Number = e.bytesLoaded / e.bytesTotal * 100;
			var iCurLength : Number;
			if (_arrTotalRes)
			{
				iCurLength = getCurLength(res[0].strUrl);
				_mcSkin.txtLoadPlanned.text = iCurLength + '/' + _arrTotalRes.length + '(' +  iCurLoad.toFixed(2) + '%)';
			}
			else
			{
				_mcSkin.txtLoadPlanned.text = iCurLoad.toFixed(2) + '%';
			}
		}
		
		protected function getCurLength(strUrl:String):int
		{
			if (!_arrLoad)
				_arrLoad = new Vector.<String>();
			for (var i:int = 0; i < _arrTotalRes.length; i++) 
			{
				if (_arrTotalRes[i].strUrl != strUrl) continue;
				if (_arrLoad.indexOf(strUrl) != -1) continue;
				_arrLoad.push(_arrTotalRes[i].strUrl);
				break;
			}
			return _arrLoad.length;
		}
		
	}

}