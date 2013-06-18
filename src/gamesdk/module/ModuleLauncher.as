package gamesdk.module {
	import flash.display.DisplayObject;
	
	import gamesdk.module.core.IModuleConfigManager;
	import gamesdk.module.core.IModuleDataCenter;
	import gamesdk.module.core.IModuleManager;
	import gamesdk.module.core.IReflector;
	import gamesdk.module.core.IScreenManager;
	import gamesdk.module.display.ScreenManager;
	import gamesdk.module.impl.ModuleBase;
	import gamesdk.module.impl.ModuleConfigManager;
	import gamesdk.module.impl.ModuleDataCenter;
	import gamesdk.module.impl.ModuleManager;
	import gamesdk.module.impl.RSLModuleManager;
	import gamesdk.module.impl.Reflector;
	import gamesdk.tools.ToolsMain;
	import gamesdk.tools.handlers.Handler;
	import gamesdk.tools.managers.ResType;
	
	import starling.display.Sprite;
	
	/**
	 * 模块启动器
	 * @author hanxianming
	 */
	public class ModuleLauncher {
		public function ModuleLauncher() {
		}
		
		/**
		 * 模块启动
		 * @param	root 根显示对象，必须为应用程序的主入口。
		 * @param	moduleConfig 模块配置文件，可以为XML配置，也可以为一个URL字符串地址。
		 * @param	launcherComplete  模块启动完成。
		 * @param	dynamicLoad  是否为动态加载模块到项目。如果为true则项目进行分模块加载，如果为false，则会不进行模块加载，但是需要手动在项目中编译模块到项目中。
		 */
		public static function launcher(nativeroot:DisplayObject, root:Sprite, moduleConfig:Object, launcherComplete:Function, dynamicLoad:Boolean = true):void {
			ToolsMain.init(nativeroot.stage);
			
			GlobalsVars.rootSprite = root;
			GlobalsVars.nativeStage = nativeroot.stage;
			GlobalsVars.dynamicLoad = dynamicLoad;
			
			var url:String = nativeroot.loaderInfo.url;
			reflector.isLocal = !(url.indexOf("file://") == -1);
			
			if (moduleConfig is XML) {
				setModulesConfig(XML(moduleConfig));
			} else if (moduleConfig is String) {
				ToolsMain.loader.load(String(moduleConfig), ResType.TXT, new Handler(launcherCompleteHandler));
			}
			
			function launcherCompleteHandler(content:String):void {
				setModulesConfig(new XML(content));
			}
			function setModulesConfig(xml:XML):void {
				configManager.setModulesConfig(xml);
				if (launcherComplete != null)
					launcherComplete.apply();
			}
			
			ModuleBase;
		}
		
		/**
		 * 模块数据管理中心。
		 */
		public static function get dataCenter():IModuleDataCenter {
			return ModuleDataCenter.instance;
		}
		
		/**
		 * 模块管理器。
		 */
		public static function get moduleManager():IModuleManager {
			if (GlobalsVars.dynamicLoad) {
				return RSLModuleManager.instance;
			}
			return ModuleManager.instance;
		}
		
		/**
		 * 模块配置。
		 */
		public static function get configManager():IModuleConfigManager {
			return ModuleConfigManager.instance;
		}
		
		/**
		 * 模块反射机制。
		 */
		public static function get reflector():IReflector {
			return Reflector.instance;
		}
		
		/**
		 * 屏幕管理器
		 */
		public static function get screenManager():IScreenManager {
			return ScreenManager.instance;
		}
		
		/**
		 * 发送模块消息，如果需要和其他模块进行交互通信可使用此API。
		 * @param	moduleType 接收消息的模块。
		 * @param	msgType 消息名称定义。
		 * @param	data 模块消息的数据。
		 */
		public static function sendModuleMsg(msgType:String, data:Object = null):void {
			moduleManager.sendModuleMessage(msgType, data);
		}
		
		/**
		 * 接收服务端消息处理。
		 * @param	msgType 服务器消息。
		 * @param	data 服务器消息的消息数据。
		 */
		public static function receiveServerMsg(msgType:uint, data:Object = null):void {
			moduleManager.receiveServerMessage(msgType, data);
		}
		
		/**
		 * 注册模块消息
		 * @param	msgType 消息类型
		 * @param	handler 消息处理器
		 */
		public static function registerModuleMsg(msgType:String, handler:Function):void {
			moduleManager.registModuleMessage(msgType, handler);
		}
		
		/**
		 * 删除模块消息
		 * @param	msgType 消息类型
		 * @param	handler 消息处理器
		 */
		public static function deleteModuleMsg(msgType:String, handler:Function):void {
			moduleManager.deleteModuleMessage(msgType, handler);
		}
		
		/**
		 * 注册服务端发来的消息
		 * @param	msgType 消息类型
		 * @param	handler 消息处理器
		 */
		public static function registServerMsg(msgType:uint, handler:Function):void {
			moduleManager.registServerMessage(msgType, handler);
		}
		
		/**
		 * 删除服务端发来的消息
		 * @param	msgType 消息类型
		 * @param	handler 消息处理器
		 */
		public static function deleteServerMsg(msgType:uint, handler:Function):void {
			moduleManager.deleteServerMessage(msgType, handler);
		}
		
		/**
		 * 切换屏幕
		 * @param	screenType 屏幕类型，需要自定义屏幕类型枚举。
		 * @param	gc 是否调用GC。
		 */
		public static function switchScreen(screenType:uint, gc:Boolean = true):void {
			screenManager.switchScreen(screenType, gc);
		}
	}
}