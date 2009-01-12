/*
 PureMVC Demo for haXe - StopWatch Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
 Copyright(c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.haxe.demos.xinf.stopwatch.view;

import org.puremvc.haxe.demos.xinf.stopwatch.proxy.StopWatchProxy;
import org.puremvc.haxe.interfaces.INotification;
import org.puremvc.haxe.patterns.mediator.Mediator;
import org.puremvc.haxe.utilities.statemachine.State;
import org.puremvc.haxe.utilities.statemachine.StateMachine;
import StopWatch;

class ApplicationMediator extends Mediator
{
	public static inline var NAME : String	= "ApplicationMediator";
	 
	public function new( viewComponent : StopWatch ) 
	{
		super( NAME, viewComponent );
	}
	
	override public function onRegister() : Void
	{
		app.addEventListener( StopWatchEvent.STOP,    handleEvent );
		app.addEventListener( StopWatchEvent.START,   handleEvent );
		app.addEventListener( StopWatchEvent.RESET,   handleEvent );
		app.addEventListener( StopWatchEvent.SPLIT,   handleEvent );
		app.addEventListener( StopWatchEvent.UNSPLIT, handleEvent );
	}
	
	override public function listNotificationInterests() : Array<String>
	{
		return [ StopWatchProxy.TICK,
				 StopWatchProxy.LAP,
				 StopWatchProxy.SYNC,
				 StopWatchProxy.RESET,
				 StateMachine.CHANGED
				];
	}
		
	override public function handleNotification( note : INotification ) : Void
	{
		switch ( note.getName() )
		{
			case StopWatchProxy.TICK:
				app.elapsed = note.getBody();
			case StopWatchProxy.LAP:
				app.laptime = note.getBody();
			case StopWatchProxy.SYNC, StopWatchProxy.RESET:
				app.elapsed = note.getBody();
				app.laptime = null;
			case StateMachine.CHANGED:
				app.state = cast( note.getBody(), State ).name;
		}
	}
	
	/**
	 * Handle events from the app.
	 *
	 * <p>For the StopWatch.ACTION_* events, we want to
	 * send a [StateMachine.ACTION] notification 
	 * with the event type being the action name.</p>
	 */  
	private function handleEvent( event : StopWatchEvent ) : Void
	{
		switch ( event.type ) 
		{
			case StopWatchEvent.STOP,
				StopWatchEvent.START,
				StopWatchEvent.RESET,
				StopWatchEvent.UNSPLIT,
				StopWatchEvent.SPLIT:
				sendNotification ( StateMachine.ACTION, null, event.type.name );
		}
	}
	
	public var app( getApp, null ) : StopWatch;
	
	public function getApp() : StopWatch
	{ 
		return viewComponent; 
	}
	
}
