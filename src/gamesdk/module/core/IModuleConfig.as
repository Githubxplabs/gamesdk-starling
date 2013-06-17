package gamesdk.module.core {
	
	/**
	 * 模块配置数据
	 * @author hanxianming
	 */
	public interface IModuleConfig {
		function get moduleType():String;
		function set moduleType(value:String):void;
		function get moduleUrl():String;
		function set moduleUrl(value:String):void;
		function get moduleName():String;
		function set moduleName(value:String):void;
		function get appDomainType():uint;
		function set appDomainType(value:uint):void;
		function get isByteArray():Boolean;
		function set isByteArray(value:Boolean):void;
	
	}

}