/*
 PureMVC Demo for haXe - StopWatch Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
 Copyright(c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.haxe.demos.xinf.stopwatch.controller;

import org.puremvc.haxe.patterns.command.MacroCommand;

class StartupCommand extends MacroCommand
{
	override function initializeMacroCommand() : Void
	{
		addSubCommand( PrepModelCommand );
		addSubCommand( PrepViewCommand  );
		addSubCommand( InjectFSMCommand ); 
	}
	
}
