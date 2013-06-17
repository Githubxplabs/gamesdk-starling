package gamesdk.module.core {
	import starling.display.DisplayObjectContainer;
	import flash.display.Loader;
	
	/**
	 * 模块接口
	 * @author hanxianming
	 */
	public interface IModule {
		function get moduleType():String;
		function init():void;
		function show(father:DisplayObjectContainer, index:int = -1):void;
		function exit():void;
		function disposeModule():void;
		function get loader():Loader;
		function set loader(value:Loader):void;
	}
}