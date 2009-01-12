/*
 PureMVC Demo for haXe - StopWatch Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
 Copyright(c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.haxe.demos.xinf.stopwatch.controller;

import org.puremvc.haxe.interfaces.INotification;
import org.puremvc.haxe.patterns.command.SimpleCommand;
import org.puremvc.haxe.demos.xinf.stopwatch.proxy.StopWatchProxy;

class PrepModelCommand extends SimpleCommand
{
	override function execute( note : INotification ) : Void
	{
		// Register the StopWatchProxy
		facade.registerProxy( new StopWatchProxy() );
	}
	
}
