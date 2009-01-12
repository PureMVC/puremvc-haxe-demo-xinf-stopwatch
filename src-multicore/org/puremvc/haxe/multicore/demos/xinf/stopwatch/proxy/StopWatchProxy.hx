/*
 PureMVC Demo for haXe - StopWatch Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
 Copyright(c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.haxe.multicore.demos.xinf.stopwatch.proxy;
	
import org.puremvc.haxe.multicore.patterns.proxy.Proxy;

class StopWatchProxy extends Proxy
{
	public static inline var NAME : String 	= "StopWatchProxy";
	public static inline var SYNC : String 	= NAME + "/notes/sync";
	public static inline var TICK : String 	= NAME + "/notes/tick";
	public static inline var LAP : String 	= NAME + "/notes/lap";
	public static inline var RESET : String = NAME + "/notes/reset";
	
	public function new()
	{
		super( NAME );
		timer = new Timer( onTick, 1000 );
	}
	
	/**
	 * Start the timer.
	 *
	 * <p>Ensure the timer exists, and has a listener 
	 * placed if this is the first call.</p>
	 *
	 * <p>Then start the timer. Note, the timer is
	 * not reset first, so this is also called 
	 * when restarting a paused timer.</p>
	 */  
	public function startTimer() : Void
	{	
		timer.start();
		sendNotification( SYNC, displayTime );
	}
	
	/**
	 * Reset the timer.
	 */
	public function resetTimer() : Void
	{
		timer.reset();
		start 	= Date.now();
		now 	= start;
		sendNotification( RESET, displayTime );
	}
	
	/**
	 * Stop the timer.
	 */
	public function stopTimer() : Void
	{
		timer.stop();
		now = Date.now();
	}
	
	/**
	 * Freeze the current lap time.
	 *
	 * <p>Send a LAP notification with the current elapsed time.</p>
	 *
	 * <p>Called when the Split button of the UI requests a split
	 * view of the current lap time (frozen) and the ongoing
	 * elapsed time as (updated with TICKS).</p>
	 */
	public function freeze() : Void 
	{
		sendNotification( LAP, displayTime );
	}
	
	/**
	 * Update the time.
	 *
	 * <p>Each second, update the time and send a 
	 * TICK notification.</p> 
	 */
	private function onTick() : Void 
	{
		now = Date.now();
		sendNotification( TICK, displayTime );
	}
	
	/**
	 * Get the display time.
	 */
	private function getDisplayTime() : { h : Int, m : Int, s : Int }
	{
		var time : Date = elapsed;
		return {
			h : time.getHours(),
			m : time.getMinutes(),
			s : time.getSeconds()
		};
	}
	
	public var displayTime( getDisplayTime, null ) : { h : Int, m : Int, s : Int };
	
	/**
	 * Get elapsed milliseconds as Date.
	 */
	private function getElapsed() : Date
	{
		return Date.fromTime( now.getTime() - start.getTime() );	
	}
	
	public var elapsed( getElapsed, null ) : Date;
	
	private var start : Date;
	private var now : Date;
	private var timer : Timer;
	
}

class Timer {
	
	var callBack : Void -> Void;
	var milliInterval : Int;
	var maxTicks : Int;
	var ticks : Int;
	var stopped : Bool;
	
	public function new( callBack : Void -> Void, ?milliInterval : Int = 1000, ?maxTicks : Int = -1 ) {
		this.callBack = callBack;
		this.milliInterval = milliInterval;
		this.maxTicks = maxTicks;
		ticks = 0;
		stopped = true;
	}

	public function start() {
		stopped = false;
		#if neko 
		tick();
		#else
		haxe.Timer.delay( tick, milliInterval );
		#end
	}
	
	public function stop() {
		stopped = true;
	}
	
	public function reset() {
		ticks = 0;
	}
	
	#if neko
	function tick() {
		var t1 = null;
		while( true ) {
			t1 = neko.vm.Thread.create( tock );
			t1.sendMessage( neko.vm.Thread.current() );
			neko.vm.Thread.readMessage( true );
			if( stopped || ticks == maxTicks )
				break;
			callBack();
			ticks++;
		}
	}
	
	function tock() {
		var main : neko.vm.Thread = neko.vm.Thread.readMessage(true);
		neko.Sys.sleep( milliInterval / 1000. );
		main.sendMessage("back to you");
	}
	#else
	function tick() {
		if( stopped || ticks == maxTicks )
			return;
		callBack();
		ticks++;
		haxe.Timer.delay( tick, milliInterval );
	}
	#end
	
}
