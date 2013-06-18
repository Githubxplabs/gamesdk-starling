package gamesdk.module.impl {
	import flash.utils.getQualifiedClassName;
	
	import gamesdk.module.core.IModuleDataCenter;
	import gamesdk.tools.ToolsMain;
	
	/**
	 * 模块数据管理中心
	 * @author hanxianming
	 */
	public class ModuleDataCenter implements IModuleDataCenter {
		private static var _instance:IModuleDataCenter;
		
		private var _classFors:Object;
		private var _useInstances:Object;
		
		public function ModuleDataCenter() {
			init();
		}
		
		private function init():void {
			_classFors = {};
			_useInstances = {};
		}
		
		public static function get instance():IModuleDataCenter {
			if (_instance == null) {
				_instance = new ModuleDataCenter();
			}
			return _instance;
		}
		
		/**
		 * @inheritDoc
		 */
		public function registDataProxyClass(whenAskedFor:Class, useinstanceClass:Class, named:String = ""):void {
			var requestName:String = getQualifiedClassName(whenAskedFor);
			_classFors[requestName + '#' + named] = useinstanceClass;
		}
		
		/**
		 * @inheritDoc
		 */
		public function registDataProxyInstance(whenAskedFor:Class, instance:Object, named:String = ""):void {
			var requestName:String = getQualifiedClassName(whenAskedFor);
			_useInstances[requestName + '#' + named] = instance;
		}
		
		/**
		 * @inheritDoc
		 */
		public function deleteDataProxyClass(whenAskedFor:Class, named:String = ""):void {
			var requestName:String = getQualifiedClassName(whenAskedFor);
			_classFors[requestName + '#' + named] = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function deleteDataProxyInstance(request:Object, named:String = ""):void {
			var requestName:String = getQualifiedClassName(request);
			_useInstances[requestName + '#' + named] = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getDataProxyByClassName(requestName:String, named:String = ""):Object {
			var key:String = requestName + '#' + named;
			var obj:Object = _useInstances[key];
			if (obj != null)
				return obj;
			obj = _classFors[key];
			if (obj is Class) {
				try {
					_useInstances[key] = new obj();
					return getDataProxyByClassName(requestName, named);
				} catch (e:Error) {
					ToolsMain.log.error("暂不支持构造函数带参数。[" + key + "]");
				}
			}
			ToolsMain.log.error("数据映射已被移除[" + key + "]");
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getDataProxyByObject(whenAskedFor:Object, named:String = ""):Object {
			return getDataProxyByClassName(getQualifiedClassName(whenAskedFor), named);
		}
	}
}