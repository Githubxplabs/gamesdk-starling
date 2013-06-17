package gamesdk.module.core {
	
	/**
	 * 游戏屏幕管理器
	 * @author hanxianming
	 */
	public interface IScreenManager {
		function get curScreen():IScreen;
		function get curScreenType():uint;
		function get screens():Vector.<IScreen>;
		function getScreenById(screenType:uint):IScreen;
		function switchScreen(screenType:uint, gc:Boolean = true):void;
		function addScreen(screen:IScreen):IScreen;
		function removeScreen(screen:IScreen):IScreen;
	}
}