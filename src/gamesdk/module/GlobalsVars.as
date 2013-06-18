package gamesdk.module {
	CONFIG::flash_display {
		import flash.display.Sprite;
	}
	CONFIG::starling_display {
		import starling.display.Sprite;
	}
	import flash.display.Stage;
	
	/**
	 * @author hanxianming
	 */
	public class GlobalsVars {
		
		public static var rootSprite:Sprite;
		public static var nativeStage:Stage;
		public static var dynamicLoad:Boolean;
		
		public function GlobalsVars() {
		
		}
	
	}

}