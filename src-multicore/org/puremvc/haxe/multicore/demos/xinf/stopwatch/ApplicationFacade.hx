/*
 PureMVC Demo for haXe - StopWatch Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
 Copyright(c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.haxe.multicore.demos.xinf.stopwatch;

import org.puremvc.haxe.multicore.demos.xinf.stopwatch.controller.EnsureTimerCommand;
import org.puremvc.haxe.multicore.demos.xinf.stopwatch.controller.FreezeDisplayCommand;
import org.puremvc.haxe.multicore.demos.xinf.stopwatch.controller.ResetDisplayCommand;
import org.puremvc.haxe.multicore.demos.xinf.stopwatch.controller.StartupCommand;
import org.puremvc.haxe.multicore.demos.xinf.stopwatch.controller.StopTimerCommand;
import org.puremvc.haxe.multicore.patterns.facade.Facade;

class ApplicationFacade extends Facade
{
	public static inline var STARTUP : String			= "startup";
	public static inline var ENSURE_TIMER : String		= "ensureTimer";
	public static inline var RESET_DISPLAY : String		= "resetDisplay";
	public static inline var FREEZE_DISPLAY : String	= "freezeDisplay";
	public static inline var STOP_TIMER : String		= "stopTimer";
	 
	public function new( key : String )
	{
		super( key );	
	}
	
	public static function getInstance( key : String ) : ApplicationFacade  {
		if( Facade.instanceMap == null )
			Facade.instanceMap = new Hash();
		if( !Facade.instanceMap.exists( key ) )
			Facade.instanceMap.set( key, new ApplicationFacade( key ) );
		return cast( Facade.instanceMap.get( key ), ApplicationFacade );
	}
	
	public function startup( app : StopWatch ) : Void
	{
		sendNotification( STARTUP, app );
	}
	
	override private function initializeController() : Void
	{
		super.initializeController();
		registerCommand( STARTUP, 		StartupCommand );	
		registerCommand( ENSURE_TIMER, 	EnsureTimerCommand );	
		registerCommand( RESET_DISPLAY, ResetDisplayCommand );	
		registerCommand( FREEZE_DISPLAY,FreezeDisplayCommand );	
		registerCommand( STOP_TIMER, 	StopTimerCommand );	
	}
	
}
