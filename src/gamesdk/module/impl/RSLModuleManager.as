package gamesdk.module.impl {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import gamesdk.module.constants.AppDomainType;
	import gamesdk.module.core.IModule;
	import gamesdk.module.core.IModuleConfig;
	import gamesdk.module.core.IModuleConfigManager;
	import gamesdk.module.core.IModuleDataCenter;
	import gamesdk.module.core.IModuleLoadInfo;
	import gamesdk.module.core.IModuleManager;
	import gamesdk.module.core.IReflector;
	import gamesdk.tools.handlers.Handler;
	import gamesdk.tools.managers.ResType;
	import gamesdk.tools.ToolsConfig;
	import gamesdk.tools.ToolsMain;
	
	/**
	 * 模块管理器
	 * @author hanxianming
	 */
	public class RSLModuleManager implements IModuleManager {
		private static var _instance:IModuleManager;
		
		protected var _loadModules:Vector.<IModuleLoadInfo>;
		protected var _moduleConfigManager:IModuleConfigManager;
		protected var _moduleDataCenter:IModuleDataCenter;
		protected var _reflector:IReflector;
		protected var _destoryModuleLock:Object;
		protected var _moduleMsgs:Object;
		protected var _serverMsgs:Dictionary;
		
		public function RSLModuleManager() {
			init();
		}
		
		private function init():void {
			
			_moduleConfigManager = ModuleConfigManager.instance;
			_reflector = Reflector.instance;
			_moduleDataCenter = ModuleDataCenter.instance;
			_loadModules = new Vector.<IModuleLoadInfo>();
			_destoryModuleLock = {};
			_moduleMsgs = {};
			_serverMsgs = new Dictionary();
		}
		
		public static function get instance():IModuleManager {
			if (_instance == null) {
				_instance = new RSLModuleManager();
			}
			return _instance;
		}
		
		/**
		 * @inheritDoc
		 */
		public function loadModule(moduleType:String, loadComplete:Function = null, loadFail:Function = null, byteArray:ByteArray = null, startLoadModule:Function = null, progress:Function = null):void {
			
			var module:IModule = getModuleByName(moduleType);
			if (module != null) {
				ToolsMain.log.warn("加载的([module]:" + moduleType + ")已经在运行中！");
				return;
			}
			
			var moduleConfig:IModuleConfig = _moduleConfigManager.getModuleConfigByType(moduleType);
			if (moduleConfig == null) {
				ToolsMain.log.error("加载([module]:" + moduleType + ")的模块在配置文件中不存在！");
				return;
			}
			
			if (byteArray == null && moduleConfig.isByteArray) {
				ToolsMain.loader.load(moduleConfig.moduleUrl, ResType.BYTE, new Handler(function(byte:ByteArray):void {
						if (byte != null) {
							loadModule(moduleType, loadComplete, loadFail, byte, startLoadModule, progress);
						} else {
							if (loadFail != null) {
								if (loadFail.length == 0) {
									loadFail.call();
								} else {
									loadFail.call(null, moduleType);
								}
							}
						}
					}));
				return;
			}
			
			var applicationDomain:ApplicationDomain;
			switch (moduleConfig.appDomainType) {
				case AppDomainType.MODULE_TYPE: 
					applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
					break;
				case AppDomainType.RSL_TYPE: 
					applicationDomain = ApplicationDomain.currentDomain;
					break;
				case AppDomainType.INDEPENDENT_TYPE: 
					applicationDomain = new ApplicationDomain();
					break;
				default: 
					applicationDomain = new ApplicationDomain();
					ToolsMain.log.warn("加载([module]:" + moduleType + ")的模块的程序域ApplicationDomain类型为位置类型！,被默认放置在独立的新域中。");
					break;
			}
			
			var ldr:Loader = new Loader();
			var moduleLoadInfo:ModuleLoadInfo = new ModuleLoadInfo(ldr, moduleConfig, startLoadModule, loadComplete, progress);
			_loadModules[_loadModules.length] = moduleLoadInfo;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, moduleLoaderCompleteHandler);
			ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, moduleLoaderProgressHandler);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, moduleLoaderIOErrorHandler);
			ldr.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			if (byteArray != null) {
				var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain);
				ldr.loadBytes(byteArray, loaderContext);
			} else {
				loaderContext = new LoaderContext(false, applicationDomain, _reflector.isLocal ? null : SecurityDomain.currentDomain);
				ldr.load(new URLRequest(moduleConfig.moduleUrl), loaderContext);
			}
			if (startLoadModule != null)
				startLoadModule(moduleType, ldr);
		}
		
		private function uncaughtErrorHandler(e:UncaughtErrorEvent):void {
			var errorInfo:String = "";
			if (e.error is Error) {
				errorInfo = "?:" + Error(e.error).message;
			} else if (e.error is IOErrorEvent) {
				errorInfo = IOErrorEvent(e.error).type + "*" + IOErrorEvent(e.error).text;
			} else if (e.error is ErrorEvent) {
				errorInfo = "*" + IOErrorEvent(e.error).text;
			} else {
				errorInfo = "未知错误 " + e.error.toString();
			}
			ToolsMain.log.error("模块发生错误", e.currentTarget.name + ":" + e.errorID, ":", e.text + "是:" + getQualifiedClassName(e.error) + "错误信息:" + errorInfo);
		}
		
		private function moduleLoaderProgressHandler(e:ProgressEvent):void {
			//var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			//var ldr:Loader = loaderInfo.loader;
			//var moduleLoaderInfo:IModuleLoadInfo = getModuleLoadInfoByLoader(ldr);
			//moduleLoaderInfo.progress.call(null, moduleLoaderInfo.configInfo.moduleType, loaderInfo.bytesLoaded / loaderInfo.bytesTotal);
		}
		
		private function moduleLoaderIOErrorHandler(e:IOErrorEvent):void {
			ToolsMain.log.error("模块加载错误:" + e.text);
		}
		
		private function moduleLoaderCompleteHandler(e:Event):void {
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			var ldr:Loader = loaderInfo.loader;
			var moduleLoaderInfo:IModuleLoadInfo = getModuleLoadInfoByLoader(ldr);
			if (ldr.content is IModule) {
				var module:IModule = ldr.content as IModule;
				moduleDataInject(module);
				moduleLoaderInfo.module = module;
				module.loader = ldr;
				module.init();
				moduleLoaderInfo.loadComplete.call(null, moduleLoaderInfo.configInfo.moduleType, ldr.content);
			} else {
				ToolsMain.log.warn("([module]:" + moduleLoaderInfo.configInfo.moduleName + ")模块未实现IModule接口，已直接运行");
			}
		}
		
		protected function moduleDataInject(obj:Object):void {
			var typeXML:XML = _reflector.getDescribeType(obj);
			for each (var node:XML in typeXML.*.(name() == 'variable' || name() == 'accessor').metadata.(@name == 'InjectData')) {
				var propertyType:String = node.parent().@type.toString();
				var propertyName:String = node.parent().@name.toString();
				var injectionName:String = node.arg.attribute('value').toString();
				obj[propertyName] = _moduleDataCenter.getDataProxyByObject(_reflector.getDefinition(propertyType), injectionName);
				moduleDataInject(obj[propertyName]);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		private function getModuleLoadInfoByLoader(ldr:Loader):IModuleLoadInfo {
			var len:int = _loadModules.length;
			for (var i:int = 0; i < len; i++) {
				var loadInfo:IModuleLoadInfo = _loadModules[i];
				if (ldr == loadInfo.loader) {
					return loadInfo;
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModuleLoadInfoByModuleType(moduleType:String):IModuleLoadInfo {
			var len:int = _loadModules.length;
			for (var i:int = 0; i < len; i++) {
				var loadInfo:IModuleLoadInfo = _loadModules[i];
				if (moduleType == loadInfo.configInfo.moduleType) {
					return loadInfo;
				}
			}
			return null;
		}
		
		private function unloadModuleByModuleType(moduleType:String):void {
			var len:int = _loadModules.length;
			for (var i:int = 0; i < len; i++) {
				var loadInfo:IModuleLoadInfo = _loadModules[i];
				if (moduleType == loadInfo.configInfo.moduleType) {
					_loadModules.splice(i, 1);
					break;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function destoryModule(moduleType:String, gc:Boolean = false):void {
			
			if (_destoryModuleLock[moduleType] == true) {
				ToolsMain.log.warn("尝试卸载的模块([module]:" + moduleType + ")正在执行卸载。");
				return;
			}
			_destoryModuleLock[moduleType] = false;
			
			var len:int = _loadModules.length;
			for (var i:int = 0; i < len; i++) {
				var loadInfo:IModuleLoadInfo = _loadModules[i];
				if (moduleType == loadInfo.configInfo.moduleType) {
					loadInfo.dispose(gc);
					_destoryModuleLock[moduleType] = false;
					_moduleMsgs[moduleType] = null;
					_loadModules.splice(i, 1);
					return;
				}
			}
			
			ToolsMain.log.warn("尝试卸载的模块([module]:" + moduleType + ")已经被卸载了。");
			_destoryModuleLock[moduleType] = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModuleByType(moduleType:String):IModule {
			var len:int = _loadModules.length;
			for (var i:int = 0; i < len; i++) {
				var loadInfo:IModuleLoadInfo = _loadModules[i];
				if (moduleType == loadInfo.configInfo.moduleType) {
					return loadInfo.module;
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModuleByName(moduleName:String):IModule {
			var len:int = _loadModules.length;
			for (var i:int = 0; i < len; i++) {
				var loadInfo:IModuleLoadInfo = _loadModules[i];
				if (moduleName == loadInfo.configInfo.moduleName) {
					return loadInfo.module;
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModuleProperties(moduleType:String, matchs:Class, properties:String, ... args):Object {
			var hasProperties:Boolean = false;
			var typeXML:XML = _reflector.getDescribeType(matchs);
			for each (var node:XML in typeXML.factory.*.(name() == 'variable' || name() == 'accessor' || name() == 'method').@name) {
				if (properties == String(node)) {
					hasProperties = true;
				}
			}
			if (!hasProperties) {
				ToolsMain.log.warn(properties + " 在 " + matchs + " 类型匹配中不存在。");
				return null;
			}
			
			var len:int = _loadModules.length;
			for (var i:int = 0; i < len; i++) {
				var loadInfo:IModuleLoadInfo = _loadModules[i];
				if (moduleType == loadInfo.configInfo.moduleType) {
					var obj:Object = null;
					if (Object(loadInfo.module).hasOwnProperty(properties)) {
						var value:* = loadInfo.module[properties];
						if (value is Function) {
							if (value.length == 0) {
								obj = value.apply(null);
							} else if (args != null && value.length == args.length) {
								try {
									obj = value.apply(null, args);
								} catch (e:Error) {
									ToolsMain.log.error(e.message);
								}
							} else {
								ToolsMain.log.error("参数个数不对，应该为：" + value.length + "个，当前为：" + (args == null ? 0 : args.length));
							}
							return obj;
						} else {
							if (args != null && args.length != 0) {
								return value = args;
							}
						}
						return value;
					} else {
						ToolsMain.log.warn("你访问的属性不存在:" + properties);
					}
				}
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function sendModuleMessage(msgType:String, data:Object = null):void {
			var msgs:Vector.<Function> = _moduleMsgs[msgType];
			if (msgs != null) {
				var len:int = msgs.length;
				for (var i:int = 0; i < len; i++) {
					msgs[i].call(null, data);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function registModuleMessage(msgType:String, handler:Function):void {
			var msgs:Vector.<Function> = _moduleMsgs[msgType];
			if (msgs == null) {
				_moduleMsgs[msgType] = msgs = new Vector.<Function>();
			}
			msgs[msgs.length] = handler;
		}
		
		/**
		 * @inheritDoc
		 */
		public function deleteModuleMessage(msgType:String, handler:Function):void {
			var msgs:Vector.<Function> = _moduleMsgs[msgType];
			if (msgs == null)
				return;
			var len:int = msgs.length;
			for (var i:int = 0; i < len; i++) {
				if (handler == msgs[i]) {
					msgs.splice(i, 1);
					return;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function registServerMessage(msgType:uint, handler:Function):void {
			var msgs:Vector.<Function> = _serverMsgs[msgType];
			if (msgs == null) {
				_serverMsgs[msgType] = msgs = new Vector.<Function>();
			}
			msgs[msgs.length] = handler;
		}
		
		/**
		 * @inheritDoc
		 */
		public function deleteServerMessage(msgType:uint, handler:Function):void {
			var msgs:Vector.<Function> = _serverMsgs[msgType];
			if (msgs == null)
				return;
			var len:int = msgs.length;
			for (var i:int = 0; i < len; i++) {
				if (handler == msgs[i]) {
					msgs.splice(i, 1);
					return;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function receiveServerMessage(msgType:uint, data:Object = null):void {
			var msgs:Vector.<Function> = _serverMsgs[msgType];
			if (msgs != null) {
				var len:int = msgs.length;
				for (var i:int = 0; i < len; i++) {
					msgs[i].call(null, data);
				}
			}
		}
	}
}
