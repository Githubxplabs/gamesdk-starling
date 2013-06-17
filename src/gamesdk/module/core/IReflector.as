package gamesdk.module.core {
	import flash.system.ApplicationDomain;
	
	/**
	 * 反射管理
	 * @author hanxianming
	 */
	public interface IReflector {
		function getDescribeType(obj:Object):XML;
		function deleteDescribeType(obj:Object):XML;
		function getDefinition(name:String):Object;
		function get applicationDomain():ApplicationDomain;
		function set applicationDomain(value:ApplicationDomain):void;
		function get isLocal():Boolean;
		function set isLocal(value:Boolean):void;
	}

}