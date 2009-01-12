/*
 PureMVC Demo for haXe - StopWatch Port by Zjnue Brzavi <zjnue.brzavi@puremvc.org>
 Copyright(c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
import Xinf;
import org.puremvc.haxe.demos.xinf.stopwatch.ApplicationFacade;

typedef ButtonData = {
	var groupId : String;
	var coverId : String;
	var action : Void -> Void;
}

typedef WatchData = {
	var doc : Dynamic;
	var watch : Watch;
	var buttons : Hash<Button>;
}

class StopWatch extends xinf.event.SimpleEventDispatcher {
	
	public static inline var NAME : String	= "StopWatch";
	
	// Action names
	public static inline var ACTION_STOP : String = NAME + "/actions/stop";
	public static inline var ACTION_START : String = NAME + "/actions/start";
	public static inline var ACTION_RESET : String = NAME + "/actions/reset";
	public static inline var ACTION_SPLIT : String = NAME + "/actions/split";
	public static inline var ACTION_UNSPLIT : String = NAME + "/actions/unsplit";
	
	// State names
	public static inline var STATE_READY : String = NAME + "/states/ready";
	public static inline var STATE_RUNNING : String = NAME + "/states/running";
	public static inline var STATE_PAUSED : String = NAME + "/states/paused";
	public static inline var STATE_STOPPED : String = NAME + "/states/stopped";
	
	public var laptime( default, setLaptime ) : TWatchTime;
	public var elapsed( default, setElapsed ) : TWatchTime;
	public var state( default, setState ) : String;
	
	var buttonData : Array<ButtonData>;
	var timeWatch : WatchData;
	var laptimeWatch : WatchData;
	
	function setLaptime( hms : TWatchTime ) : TWatchTime {
		if( laptimeWatch.watch == null ) return hms;
		if( hms == null ) {
			laptimeWatch.watch.show = false;
		} else {
			laptimeWatch.watch.time = hms;
			laptimeWatch.watch.show = true;
		}
		return hms;
	}
	
	function setElapsed( hms : TWatchTime ) : TWatchTime {
		if( timeWatch.watch == null ) return hms;
		timeWatch.watch.time = hms;
		return hms;
	}
	
	function setState( state : String ) : String {
		if( timeWatch.buttons == null ) return state;
		timeWatch.buttons.get( "start_btn" ).enabled = (state == STATE_READY);
		timeWatch.buttons.get( "stop_btn" ).enabled = (state == STATE_RUNNING || state == STATE_PAUSED);
		timeWatch.buttons.get( "reset_btn" ).enabled = (state == STATE_STOPPED);
		timeWatch.buttons.get( "split_btn" ).enabled = (state == STATE_RUNNING);
		timeWatch.buttons.get( "unsplit_btn" ).enabled = (state == STATE_PAUSED);
		return state;
	}
	
	public function new() {
		super();
		
		buttonData = [
			{ groupId : "start_btn", coverId : "start_btn_cover", action : onStart },
			{ groupId : "stop_btn", coverId : "stop_btn_cover", action : onStop },
			{ groupId : "reset_btn", coverId : "reset_btn_cover", action : onReset },
			{ groupId : "split_btn", coverId : "split_btn_cover", action : onSplit },
			{ groupId : "unsplit_btn", coverId : "unsplit_btn_cover", action : onUnsplit },
		];
        
		#if js
		
		var doc : Dynamic = untyped document.getElementById( "js_time" ).getSVGDocument();
		timeWatch = {
			doc : doc,
			watch : new Watch( doc, "watch", "hour", "minute", "second" ),
			buttons : getButtons( doc )
		};
		doc = untyped document.getElementById( "js_laptime" ).getSVGDocument();
		laptimeWatch = {
			doc : doc,
			watch : new Watch( doc, "watch", "hour", "minute", "second" ),
			buttons : getButtons( doc )
		};
		showButtons( laptimeWatch.doc, false );
		laptimeWatch.watch.show = false;
		
		ApplicationFacade.getInstance().startup( this );
		
		#else
		
		timeWatch = {
			doc : new Document(),
			watch : null,
			buttons : null
		};
		laptimeWatch = {
			doc : new Document(),
			watch : null,
			buttons : null
		}; 
		Document.load( "clock.svg", timeWatch.doc, onLoad1, onError, Svg ); // hmm, copy - don't load twice
		Document.load( "clock.svg", laptimeWatch.doc, onLoad2, onError, Svg );
		
		#end
	}
	
	function getButtons( doc : Dynamic ) : Hash<Button> {
		var buttons = new Hash<Button>();
		for( d in buttonData )
			buttons.set( d.groupId, new Button( doc, d.groupId, d.coverId, d.action, false ) );
		return buttons;
	}
    
	function showButtons( doc : Dynamic, b : Bool ) {
		#if js
		untyped doc.getElementById( "buttons" ).setAttribute( "opacity", if(b) "1" else "0" );
		#else
		cast( doc.getElementById( "buttons" ), xinf.ony.Element ).visibility = if(b) xinf.ony.type.Visibility.Visible else xinf.ony.type.Visibility.Hidden;
		#end
	}
	
	function onLoad1( data : Svg ) {
		Root.appendChild( data );
		timeWatch.watch = new Watch( timeWatch.doc, "watch", "hour", "minute", "second" );
		timeWatch.buttons = getButtons( timeWatch.doc );
	}
	
	function onLoad2( data : Svg ) {
		Root.appendChild( data );
		laptimeWatch.watch = new Watch( laptimeWatch.doc, "watch", "hour", "minute", "second" );
		laptimeWatch.buttons = getButtons( laptimeWatch.doc );
		showButtons( laptimeWatch.doc, false );
		laptimeWatch.watch.show = false;
		data.transform = new Translate( 300., 0 );
		Root.main();
		ApplicationFacade.getInstance().startup( this );
	}
	
	function onError(e:String) {
		trace("Could not load SVG source.\n"+e);
	}
	
	function onStop() { dispatchEvent( new StopWatchEvent( StopWatchEvent.STOP ) ); }
	function onStart() { dispatchEvent( new StopWatchEvent( StopWatchEvent.START ) ); }
	function onReset() { dispatchEvent( new StopWatchEvent( StopWatchEvent.RESET ) ); }
	function onSplit() { dispatchEvent( new StopWatchEvent( StopWatchEvent.SPLIT ) ); }
	function onUnsplit() { dispatchEvent( new StopWatchEvent( StopWatchEvent.UNSPLIT ) ); }
	
	static function main() {
		try {
			new StopWatch();
		} catch( e : Dynamic ) {
			trace("err or " + Std.string(e));
		}
	}
    
}

typedef TWatchTime = {
	var h : Int;
	var m : Int;
	var s : Int;
}

class Watch {
	
	var doc : Dynamic;
	var watchId : String;
	var hourId : String;
	var minId : String;
	var secId : String;
	
	public var time( default, setTime ) : TWatchTime;
	public var show( default, setShow ) : Bool;

	public function new( doc : Dynamic, watchId : String, hourId : String, minId : String, secId : String ) {
		this.doc = doc;
		this.watchId = watchId;
		this.hourId = hourId;
		this.minId = minId;
		this.secId = secId;
	}
	
	function setTime( t : TWatchTime ) : TWatchTime {
		time = t;
		#if js
		//js works with degrees, not radians
		untyped doc.getElementById( hourId ).setAttribute( "transform", "rotate( " + Std.string( t.h * 6 ) + ")" );
		untyped doc.getElementById( minId ).setAttribute( "transform", "rotate( " + Std.string( t.m * 6 ) + ")" );
		untyped doc.getElementById( secId ).setAttribute( "transform", "rotate( " + Std.string( t.s * 6 ) + ")" );
		#else
		cast( doc.getElementById( hourId ), xinf.ony.Element ).transform = new Rotate( t.h * 2 * Math.PI / 60 );
		cast( doc.getElementById( minId ), xinf.ony.Element ).transform = new Rotate( t.m * 2 * Math.PI / 60 );
		cast( doc.getElementById( secId ), xinf.ony.Element ).transform = new Rotate( t.s * 2 * Math.PI / 60 );
		#end
		return t;
	}
	
	function setShow( s : Bool ) : Bool {
		show = s;
		#if js
		untyped doc.getElementById( watchId ).setAttribute( "opacity", if(s) "1" else "0" );
		#else
		cast( doc.getElementById( watchId ), xinf.ony.Element ).visibility = if(s) xinf.ony.type.Visibility.Visible else xinf.ony.type.Visibility.Hidden;
		#end
		return s;
	}
	
}

class Button {
	
	var doc : Dynamic;
	var groupId : String;
	var coverId : String;
	var action : Void -> Void;
	
	public var enabled( default, setEnabled ) : Bool;
	
	public function new( doc : Dynamic, groupId : String, coverId : String, action : Void -> Void, ?enabled : Bool = true ) {
		this.doc = doc;
		this.groupId = groupId;
		this.coverId = coverId;
		this.action = action;
		this.enabled = enabled;
		setHandler();
	}
	
	function setHandler() {
		#if js
		Reflect.setField( untyped doc.getElementById( groupId ), "onclick", onClick );
		#else
		cast( doc.getElementById( groupId ), xinf.ony.Element ).addEventListener( xinf.event.MouseEvent.MOUSE_DOWN, onClick );
		#end
	}
	
	function setEnabled( b : Bool ) : Bool {
		enabled = b;
		#if js
		untyped doc.getElementById( coverId ).setAttribute( "opacity", if(b) "0" else ".7" );
		#else
		cast( doc.getElementById( coverId ), xinf.ony.Element ).opacity = if(b) 0. else .7;
		#end
		return b;
	}
	
	function onClick( e : Dynamic ) {
		if( this.enabled )
			action();
	}
	
}

class StopWatchEvent extends xinf.event.Event<StopWatchEvent> {
	
	static public var STOP = new xinf.event.EventKind<StopWatchEvent>( StopWatch.ACTION_STOP );
	static public var START = new xinf.event.EventKind<StopWatchEvent>( StopWatch.ACTION_START );
	static public var RESET = new xinf.event.EventKind<StopWatchEvent>( StopWatch.ACTION_RESET );
	static public var SPLIT = new xinf.event.EventKind<StopWatchEvent>( StopWatch.ACTION_SPLIT );
	static public var UNSPLIT = new xinf.event.EventKind<StopWatchEvent>( StopWatch.ACTION_UNSPLIT );

	public function new( _type : xinf.event.EventKind<StopWatchEvent> ) {
		super(_type);
	}

	override public function toString() : String {
		return type+"()";
	}
	
}
