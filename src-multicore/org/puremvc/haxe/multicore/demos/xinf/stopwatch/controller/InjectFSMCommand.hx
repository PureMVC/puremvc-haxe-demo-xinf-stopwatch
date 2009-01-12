/*
 PureMVC Demo for haXe - StopWatch Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
 Copyright(c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.haxe.multicore.demos.xinf.stopwatch.controller;

import org.puremvc.haxe.multicore.demos.xinf.stopwatch.ApplicationFacade;
import org.puremvc.haxe.multicore.interfaces.INotification;
import org.puremvc.haxe.multicore.patterns.command.SimpleCommand;
import org.puremvc.haxe.multicore.utilities.statemachine.FSMInjector;

/**
 * Create and inject the StateMachine.
 */
class InjectFSMCommand extends SimpleCommand
{
	/**
	 * Inject the Finite State Machine.
	 *
	 * <p>Though the Xml could come from anywhere, even loaded remotely,
	 * we are simply creating it here in this command since it is 
	 * easy to refefence the StopWatch ACTION and STATE constants,
	 * so they will match up with the events acutally being sent from
	 * the stopwatch view.</p>
	 * 
	 * <p>Then we use the [FSMInjector] to create the configured 
	 * [StateMachine] from the Xml FSM description and 'inject' 
	 * it into the PureMVC apparatus.</p>
	 *
	 * <p>The [StateMachine] is registered as an [IMediator], 
	 * interested in [StateMachine.ACTION] Notifications. The 
	 * [type] parameter of those Notifications must be a valid 
	 * registered [State] in the FSM.</p>
	 */
	override public function execute( note : INotification ) : Void
	{
		// Create the FSM definition
		var xmlStr =
		"<fsm initial=\"" + StopWatch.STATE_READY + "\">
		   <state name=\"" + StopWatch.STATE_READY + "\" entering=\"" + ApplicationFacade.RESET_DISPLAY + "\">
		       <transition action=\"" + StopWatch.ACTION_START + "\" target=\"" + StopWatch.STATE_RUNNING + "\"/>
		   </state>
		   <state name=\"" + StopWatch.STATE_RUNNING + "\" entering=\"" + ApplicationFacade.ENSURE_TIMER + "\">
		       <transition action=\"" + StopWatch.ACTION_SPLIT + "\" target=\"" + StopWatch.STATE_PAUSED + "\"/>
		       <transition action=\"" + StopWatch.ACTION_STOP + "\" target=\"" + StopWatch.STATE_STOPPED + "\"/>
		   </state>
		   <state name=\"" + StopWatch.STATE_PAUSED + "\" entering=\"" + ApplicationFacade.FREEZE_DISPLAY + "\">
		       <transition action=\"" + StopWatch.ACTION_UNSPLIT + "\" target=\"" + StopWatch.STATE_RUNNING + "\"/>
		       <transition action=\"" + StopWatch.ACTION_STOP + "\" target=\"" + StopWatch.STATE_STOPPED + "\"/>
		   </state>
		   <state name=\"" + StopWatch.STATE_STOPPED + "\" entering=\"" + ApplicationFacade.STOP_TIMER + "\">
		       <transition action=\"" + StopWatch.ACTION_RESET + "\" target=\"" + StopWatch.STATE_READY + "\"/>
		   </state>
		</fsm>";
		var fsm = Xml.parse( xmlStr ).firstElement();
		
		// Create and inject the StateMachine 
		var injector = new FSMInjector( fsm );
		injector.initializeNotifier( this.multitonKey );
		injector.inject();
	}
	
}
