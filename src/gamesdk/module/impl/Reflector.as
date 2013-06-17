package gamesdk.module.impl {
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import gamesdk.module.core.IReflector;
	
	/**
	 * 反射管理
	 * @author hanxianming
	 */
	public class Reflector implements IReflector {
		private static var _instance:IReflector;
		private var _classXmlTypes:Object;
		private var _applicationDomain:ApplicationDomain;
		private var _isLocal:Boolean;
		
		public function Reflector() {
			init();
		}
		
		private function init():void {
			_classXmlTypes = {};
		}
		
		public static function get instance():IReflector {
			if (_instance == null) {
				_instance = new Reflector();
			}
			return _instance;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getDescribeType(obj:Object):XML {
			var className:String = getQualifiedClassName(obj);
			var typeXML:XML = _classXmlTypes[className];
			if (typeXML == null) {
				_classXmlTypes[className] = typeXML = describeType(obj);
			}
			return typeXML;
		}
		
		/**
		 * @inheritDoc
		 */
		public function deleteDescribeType(obj:Object):XML {
			var className:String = getQualifiedClassName(obj);
			var typeXML:XML = _classXmlTypes[className];
			if (typeXML != null) {
				_classXmlTypes[className] = null;
			}
			return typeXML;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get applicationDomain():ApplicationDomain {
			return _applicationDomain ? _applicationDomain : ApplicationDomain.currentDomain;
		}
		
		public function set applicationDomain(applicationDomain:ApplicationDomain):void {
			_applicationDomain = applicationDomain;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getDefinition(name:String):Object {
			return applicationDomain.getDefinition(name);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isLocal():Boolean {
			return _isLocal;
		}
		
		public function set isLocal(value:Boolean):void {
			_isLocal = value;
		}
	}

}