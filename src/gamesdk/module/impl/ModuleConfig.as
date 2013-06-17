package gamesdk.module.impl {
	import gamesdk.module.core.IModuleConfig;
	
	/**
	 * ...
	 * @author hanxianming
	 */
	public class ModuleConfig implements IModuleConfig {
		private var _moduleType:String;
		private var _moduleUrl:String;
		private var _moduleName:String;
		private var _appDomainType:uint;
		private var _isByteArray:Boolean;
		
		public function ModuleConfig() {
		
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moduleType():String {
			return _moduleType;
		}
		
		public function set moduleType(value:String):void {
			_moduleType = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moduleUrl():String {
			return _moduleUrl;
		}
		
		public function set moduleUrl(value:String):void {
			_moduleUrl = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moduleName():String {
			return _moduleName;
		}
		
		public function set moduleName(value:String):void {
			_moduleName = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get appDomainType():uint {
			return _appDomainType;
		}
		
		public function set appDomainType(value:uint):void {
			_appDomainType = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isByteArray():Boolean {
			return _isByteArray;
		}
		
		public function set isByteArray(value:Boolean):void {
			_isByteArray = value;
		}
	}

}