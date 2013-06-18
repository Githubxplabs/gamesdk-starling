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
		
		/**
		 * @inheritDoc
		 */
		public function classExtendsOrImplements(classOrClassName:Object, superclass:Class):Boolean {
			var actualClass:Class;
			
			if (classOrClassName is Class) {
				actualClass = Class(classOrClassName);
			} else if (classOrClassName is String) {
				try {
					actualClass = Class(getDefinitionByName(classOrClassName as String));
				} catch (e:Error) {
					throw new Error("The class name " + classOrClassName + " is not valid because of " + e + "\n" + e.getStackTrace());
				}
			}
			
			if (!actualClass) {
				throw new Error("The parameter classOrClassName must be a valid Class " + "instance or fully qualified class name.");
			}
			
			if (actualClass == superclass)
				return true;
			
			var factoryDescription:XML = getDescribeType(actualClass).factory[0];
			return (factoryDescription.children().(name() == "implementsInterface" || name() == "extendsClass").(attribute("type") == getQualifiedClassName(superclass)).length() > 0);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getClass(value:*):Class {
			if (value is Class) {
				return value;
			}
			return getConstructor(value);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getFQCN(value:*, replaceColons:Boolean = false):String {
			var fqcn:String;
			if (value is String) {
				fqcn = value;
				// Add colons if missing and desired.
				if (!replaceColons && fqcn.indexOf('::') == -1) {
					var lastDotIndex:int = fqcn.lastIndexOf('.');
					if (lastDotIndex == -1)
						return fqcn;
					return fqcn.substring(0, lastDotIndex) + '::' + fqcn.substring(lastDotIndex + 1);
				}
			} else {
				fqcn = getQualifiedClassName(value);
			}
			return replaceColons ? fqcn.replace('::', '.') : fqcn;
		}
	}

}