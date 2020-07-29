package coconut.dragdrop;

import h2d.*;
import why.dragdrop.*;
import tink.state.Observable;
using tink.CoreApi;

class DraggableModel<Item, Result> implements coconut.data.Model {
	@:constant var type:String;
	@:constant var manager:Manager<Item, Result, PureInteractive>;
	@:constant var isDragging:Item->Bool;
	@:constant var canDrag:()->Bool;
	@:constant var onDragStart:()->Item;
	@:constant var onDragEnd:()->Void;
	
	@:editable var interactive:PureInteractive = null;
	
	@:computed var source:Source<Item, Result> = new Source({
		beginDrag: (ctx, id) -> onDragStart(),
		endDrag: (ctx, id) -> {
			lastPosition = ctx.getSourceClientOffset();
			onDragEnd();
		},
		canDrag: (ctx, id) -> canDrag(),
		isDragging: (ctx, id) -> isDragging(ctx.getItem()),
	});
	
	@:skipCheck @:computed var registry:Registry<Item, Result> = manager.getRegistry();
	@:computed var sourceId:SourceId = registry.addSource(type, source);
	@:computed var connection:CallbackLink = {
		$last.orNull().cancel();
		if(interactive == null) null;
		else manager.getBackend().connectDragSource(sourceId, interactive, {});
	}
	
	@:editable var lastPosition:tink.s2d.Point = tink.s2d.Point.xy(0, 0);
	@:external var sourcePosition:tink.s2d.Point;
	
	public function dispose() {
		connection.cancel();
		registry.removeSource(sourceId);
	}
}

@:observable abstract PureInteractive(Interactive) from Interactive to Interactive {}

class Draggable<Item, Result> extends coconut.h2d.View {
	@:attr var manager:Manager<Item, Result, PureInteractive>;
	@:attr var type:String;
	@:attr var isDragging:Item->Bool;
	@:attr var canDrag:()->Bool;
	@:attr var onDragStart:()->Item;
	@:attr var onDragEnd:()->Void;
	
	@:computed var model:DraggableModel<Item, Result> =
		new DraggableModel({
			type: type, 
			manager: manager, 
			isDragging: isDragging,
			canDrag: canDrag,
			onDragStart: onDragStart,
			onDragEnd: onDragEnd,
			sourcePosition: manager.getMonitor().getSourceClientOffset(),
		});
	
	@:computed var x:Int = Std.int((model.sourcePosition == null ? model.lastPosition : model.sourcePosition).x);
	@:computed var y:Int = Std.int((model.sourcePosition == null ? model.lastPosition : model.sourcePosition).y);
	@:computed var connection:CallbackLink = model.connection;
	
	function render() '
		<Interactive x=${x} y=${y} width=${100} height=${20} backgroundColor=${0xFFCCCCCC} onClick=${trace('clicked')} ref=${v -> model.interactive = v}>
			<Text x=${50} y=${2} font=${hxd.res.DefaultFont.get()} text=${model.sourceId + ':' + model.type + ':' + (connection == null) + ':' + model.manager.getMonitor().isDragging()} textAlign=${Center} textColor=${0} />
		</Interactive>
	';
	
	override function viewWillUnmount() {
		model.dispose();
	}
}

@:structInit
private class Source<Item, Result> implements DragSource<Item, Result> {
	final _beginDrag:(ctx:Context<Item, Result>, sourceId:SourceId)->Item;
	final _endDrag:(ctx:Context<Item, Result>, sourceId:SourceId)->Void;
	final _canDrag:(ctx:Context<Item, Result>, sourceId:SourceId)->Bool;
	final _isDragging:(ctx:Context<Item, Result>, sourceId:SourceId)->Bool;
	
	public inline function new(o) {
		_beginDrag = o.beginDrag;
		_endDrag = o.endDrag;
		_canDrag = o.canDrag;
		_isDragging = o.isDragging;
	}

	public function beginDrag(ctx:Context<Item, Result>, sourceId:SourceId):Item {
		return _beginDrag(ctx, sourceId);
	}

	public function endDrag(ctx:Context<Item, Result>, sourceId:SourceId):Void {
		return _endDrag(ctx, sourceId);
	}

	public function canDrag(ctx:Context<Item, Result>, sourceId:SourceId):Bool {
		return _canDrag(ctx, sourceId);
	}

	public function isDragging(ctx:Context<Item, Result>, sourceId:SourceId):Bool {
		return _isDragging(ctx, sourceId);
	}
}