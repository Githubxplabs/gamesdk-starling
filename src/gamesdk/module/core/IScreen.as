package gamesdk.module.core {
	import starling.display.DisplayObjectContainer;
	
	/**
	 * 游戏的屏幕接口
	 * @author hanxianming
	 */
	public interface IScreen {
		function get screenType():uint;
		function set screenType(value:uint):void;
		function get screenName():String;
		function set screenName(value:String):void;
		function get fatherDisplay():DisplayObjectContainer;
		function set fatherDisplay(value:DisplayObjectContainer):void;
		
		function show():void;
		function disposeScreen():void;
		function removeAllDisplay():void;
		function removeScreenFromParent():void;
		function destory():void;
		function deleteFromScreens():void;
	}
}