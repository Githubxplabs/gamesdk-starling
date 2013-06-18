package gamesdk.module.impl {
	import flash.utils.ByteArray;
	
	import gamesdk.module.core.IModule;
	import gamesdk.module.core.IModuleConfig;
	import gamesdk.module.core.IModuleManager;
	import gamesdk.tools.ToolsMain;
	
	/**
	 * ...
	 * @author hanxianming
	 */
	public class ModuleManager extends RSLModuleManager {
		private static var _instance:IModuleManager;
		
		public function ModuleManager() {
			super();
		}
		
		public static function get instance():IModuleManager {
			if (_instance == null) {
				_instance = new ModuleManager();
			}
			return _instance;
		}
		
		override public function loadModule(moduleType:String, loadComplete:Function = null, loadFail:Function = null, byteArray:ByteArray = null, startLoadModule:Function = null, progress:Function = null):void {
			var module:IModule = getModuleByName(moduleType);
			if (module != null) {
				ToolsMain.log.warn("加载的([module]:" + moduleType + ")已经在运行中！");
				return;
			}
			var moduleConfig:IModuleConfig = _moduleConfigManager.getModuleConfigByType(moduleType);
			if (moduleConfig == null) {
				ToolsMain.log.error("加载([module]:" + moduleType + ")的模块在配置文件中不存在！");
				return;
			}
			
			var definitionName:String = moduleConfig.moduleUrl;
			definitionName = definitionName.slice(0, definitionName.lastIndexOf("."));
			definitionName = definitionName.replace(/\//g, ".");
			
			var objClass:* = _reflector.applicationDomain.getDefinition(definitionName);
			module = new objClass();
			
			var loadInfo:ModuleLoadInfo = new ModuleLoadInfo(null, moduleConfig, startLoadModule, loadComplete, progress);
			_loadModules[_loadModules.length] = loadInfo;
			moduleDataInject(module);
			loadInfo.module = module;
			module.init();
			loadInfo.loadComplete.call(null, moduleType, module);
		}
	
	}

}