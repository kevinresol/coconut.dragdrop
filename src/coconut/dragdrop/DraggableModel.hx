package coconut.dragdrop;

import why.dragdrop.*;
using tink.CoreApi;

class DraggableModel<Item, Result, Attrs, Node> implements coconut.data.Model {
	@:constant var type:String;
	@:constant var manager:Manager<Item, Result, Node>;
	@:constant var isDragging:Item->Bool;
	@:constant var canDrag:()->Bool;
	@:constant var onDragStart:()->Item;
	@:constant var onDragEnd:Context<Item, Result>->Void;
	@:constant var collect:Context<Item, Result>->Attrs;
	
	@:editable private var node:Node = null;
	
	@:computed var source:Source<Item, Result> = new Source({
		beginDrag: (ctx, id) -> onDragStart(),
		endDrag: (ctx, id) -> onDragEnd(ctx),
		canDrag: (ctx, id) -> canDrag(),
		isDragging: (ctx, id) -> isDragging(ctx.getItem()),
	});
	
	@:skipCheck @:computed var registry:Registry<Item, Result> = manager.getRegistry();
	@:computed var sourceId:SourceId = {
		switch ($last) {
			case Some(id): registry.removeSource(id);
			case None:
		}
		registry.addSource(type, source);
	}
	@:computed var connection:CallbackLink = {
		$last.orNull().cancel();
		if(node == null) null;
		else manager.getBackend().connectDragSource(sourceId, node, {});
	}
	@:computed var attrs:Attrs = {
		connection; // HACK: make it tracked
		collect == null ? null : collect(manager.getMonitor());
	}
	
	public function ref(node) 
		this.node = node;
	
	public function dispose() {
		connection.cancel();
		registry.removeSource(sourceId);
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