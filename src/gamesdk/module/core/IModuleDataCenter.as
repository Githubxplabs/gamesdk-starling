package gamesdk.module.core {
	
	/**
	 * 模块数据管理中心
	 * @author hanxianming
	 */
	public interface IModuleDataCenter {
		function registDataProxyClass(whenAskedFor:Class, useinstanceClass:Class, named:String = ""):void;
		function registDataProxyInstance(whenAskedFor:Class, instance:Object, named:String = ""):void
		function deleteDataProxyClass(whenAskedFor:Class, named:String = ""):void;
		function deleteDataProxyInstance(request:Object, named:String = ""):void;
		function getDataProxyByClassName(requestName:String, named:String = ""):Object;
		function getDataProxyByObject(whenAskedFor:Object, named:String = ""):Object;
	
	}

}