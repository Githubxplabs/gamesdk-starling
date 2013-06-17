package gamesdk.module.impl {
	import gamesdk.module.core.IModuleConfig;
	import gamesdk.module.core.IModuleConfigManager;
	
	/**
	 * 多模块配置文件
	 * @author hanxianming
	 */
	public class ModuleConfigManager implements IModuleConfigManager {
		private static var _instance:IModuleConfigManager;
		
		private var _configs:Vector.<ModuleConfig>;
		
		public function ModuleConfigManager() {
			init();
		}
		
		private function init():void {
			
			_configs = new Vector.<ModuleConfig>();
		}
		
		public static function get instance():IModuleConfigManager {
			if (_instance == null) {
				_instance = new ModuleConfigManager();
			}
			return _instance;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function getModuleConfigByType(moduleType:String):IModuleConfig {
			var len:int = _configs.length;
			for (var i:int = 0; i < len; i++) {
				if (moduleType == _configs[i].moduleType) {
					return _configs[i];
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModuleConfigByUrl(moduleUrl:String):IModuleConfig {
			var len:int = _configs.length;
			for (var i:int = 0; i < len; i++) {
				if (moduleUrl == _configs[i].moduleUrl) {
					return _configs[i];
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModuleConfigByName(moduleName:String):IModuleConfig {
			var len:int = _configs.length;
			for (var i:int = 0; i < len; i++) {
				if (moduleName == _configs[i].moduleName) {
					return _configs[i];
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setModulesConfig(xml:XML):void {
			for each (var item:XML in xml.modules.module) {
				var config:ModuleConfig = new ModuleConfig();
				config.moduleType = item.moduleType;
				config.moduleUrl = item.moduleUrl;
				config.moduleName = item.moduleName;
				config.appDomainType = item.appDomainType;
				config.isByteArray = String(item.isByteArray) == "true";
				_configs[_configs.length] = config;
			}
		}
	}

}