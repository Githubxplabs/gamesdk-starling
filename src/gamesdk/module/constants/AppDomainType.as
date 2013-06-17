package gamesdk.module.constants {
	
	/**
	 * 加载模块的Domain类型。
	 * @author hanxianming
	 */
	public class AppDomainType {
		/** 加载到子域(模块)*/
		public static const MODULE_TYPE:int = 1;
		/** 加载到同域(运行时共享库)*/
		public static const RSL_TYPE:int = 2;
		/** 加载到新域(独立运行的程序或模块)*/
		public static const INDEPENDENT_TYPE:int = 3;
		
		public function AppDomainType() {
		
		}
	
	}

}