package gamesdk.module.display {
	import gamesdk.module.GlobalsVars;
	import gamesdk.module.core.IScreen;
	import gamesdk.module.core.IScreenManager;
	import gamesdk.tools.ToolsMain;
	
	import starling.display.DisplayObject;
	
	/**
	 * ...
	 * @author hanxianming
	 */
	public class ScreenManager implements IScreenManager {
		private static var _instance:IScreenManager;
		
		private var _screens:Vector.<IScreen>;
		private var _curScreen:IScreen;
		
		public function ScreenManager() {
			init();
		}
		
		private function init():void {
			_screens = new Vector.<IScreen>();
		}
		
		public static function get instance():IScreenManager {
			if (_instance == null) {
				_instance = new ScreenManager();
			}
			return _instance;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get curScreen():IScreen {
			return _curScreen;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get curScreenType():uint {
			if (_curScreen == null)
				return 0;
			return _curScreen.screenType;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get screens():Vector.<IScreen> {
			return _screens;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getScreenById(screenType:uint):IScreen {
			var len:int = _screens.length
			for (var i:int = 0; i < len; i++) {
				if (screenType == _screens[i].screenType) {
					return _screens[i];
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function switchScreen(screenType:uint, gc:Boolean = true):void {
			if (curScreenType == screenType)
				return;
			
			var screen:IScreen = getScreenById(screenType);
			if (screen == null)
				return;
			
			if (_curScreen != null) {
				_curScreen.removeScreenFromParent();
				_curScreen.disposeScreen();
			}
			
			if (gc)
				ToolsMain.gc.gc();
			
			_curScreen = screen;
			_curScreen.fatherDisplay = GlobalsVars.rootSprite;
			GlobalsVars.rootSprite.addChild(DisplayObject(_curScreen));
			_curScreen.show();
		}
		
		/**
		 * @inheritDoc
		 */
		public function addScreen(screen:IScreen):IScreen {
			if (screen == null)
				return null;
			var len:int = _screens.length
			for (var i:int = 0; i < len; i++) {
				if (screen == _screens[i]) {
					return screen;
				}
			}
			return _screens[len] = screen;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeScreen(screen:IScreen):IScreen {
			if (screen == null)
				return null;
			var len:int = _screens.length;
			for (var i:int = 0; i < len; i++) {
				if (screen == _screens[i]) {
					screen.removeScreenFromParent();
					screen.removeAllDisplay();
					screen.disposeScreen();
					screen.destory();
					return _screens.splice(i, 1)[0];
				}
			}
			return null;
		}
	
	}

}