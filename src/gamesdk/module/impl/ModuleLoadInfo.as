package gamesdk.module.impl {
	import flash.display.Loader;
	
	import gamesdk.module.GlobalsVars;
	import gamesdk.module.core.IModule;
	import gamesdk.module.core.IModuleConfig;
	import gamesdk.module.core.IModuleLoadInfo;
	import gamesdk.tools.ToolsMain;
	
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author hanxianming
	 */
	public class ModuleLoadInfo implements IModuleLoadInfo {
		private var _loader:Loader;
		private var _module:IModule;
		private var _configInfo:IModuleConfig;
		private var _startLoadModule:Function;
		private var _loadComplete:Function;
		private var _progress:Function;
		
		public function ModuleLoadInfo(loader:Loader, configInfo:IModuleConfig, startLoadModule:Function, loadComplete:Function, progress:Function = null, module:IModule = null) {
			this._loader = loader;
			this._configInfo = configInfo;
			this._module = module;
			this._startLoadModule = startLoadModule;
			this._loadComplete = loadComplete;
			this._progress = progress;
		}
		
		/* INTERFACE module.core.IModuleLoadInfo */
		
		/**
		 * @inheritDoc
		 */
		public function get loader():Loader {
			return _loader;
		}
		
		public function set loader(value:Loader):void {
			_loader = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get module():IModule {
			return _module;
		}
		
		public function set module(value:IModule):void {
			_module = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get configInfo():IModuleConfig {
			return _configInfo;
		}
		
		public function set configInfo(value:IModuleConfig):void {
			_configInfo = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get startLoadModule():Function {
			return _startLoadModule;
		}
		
		public function set startLoadModule(value:Function):void {
			_startLoadModule = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loadComplete():Function {
			return _loadComplete;
		}
		
		public function set loadComplete(value:Function):void {
			_loadComplete = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get progress():Function {
			return _progress;
		}
		
		public function set progress(value:Function):void {
			_progress = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose(gc:Boolean = false):void {
			if (GlobalsVars.dynamicLoad) {
				try {
					_loader.unloadAndStop(true);
				} catch (e:Error) {
					_loader.unload();
					ToolsMain.timer.doOnce(1000, ToolsMain.gc.gc);
				}
			}
			if (DisplayObject(module).parent != null)
				DisplayObject(module).parent.removeChild(DisplayObject(module));
			if (gc)
				ToolsMain.timer.doOnce(1000, ToolsMain.gc.gc);
			
			ToolsMain.log.info("模块([module]:" + _configInfo.moduleType + ")被卸载销毁。");
			
			if (_module) {
				_module.exit();
				_module.disposeModule();
			}
			
			this._loader = null;
			this._configInfo = null;
			this._module = null;
			this._startLoadModule = null;
			this._loadComplete = null;
			this._progress = null;
		}
	}

}