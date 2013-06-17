package gamesdk.module.core {
	
	/**
	 * 所有模块配置管理
	 * @author hanxianming
	 */
	public interface IModuleConfigManager {
		function getModuleConfigByType(moduleType:String):IModuleConfig;
		function getModuleConfigByUrl(moduleUrl:String):IModuleConfig;
		function getModuleConfigByName(moduleName:String):IModuleConfig;
		function setModulesConfig(xml:XML):void;
	}

}