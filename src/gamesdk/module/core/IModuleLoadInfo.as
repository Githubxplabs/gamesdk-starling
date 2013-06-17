package gamesdk.module.core {
	import flash.display.Loader;
	
	/**
	 * 加载的模块信息
	 * @author hanxianming
	 */
	public interface IModuleLoadInfo {
		function get loader():Loader;
		function set loader(value:Loader):void;
		function get module():IModule;
		function set module(value:IModule):void;
		function get configInfo():IModuleConfig;
		function set configInfo(value:IModuleConfig):void;
		function get startLoadModule():Function;
		function set startLoadModule(value:Function):void;
		function get loadComplete():Function;
		function set loadComplete(value:Function):void;
		function get progress():Function;
		function set progress(value:Function):void;
		function dispose(gc:Boolean = false):void;
	}

}