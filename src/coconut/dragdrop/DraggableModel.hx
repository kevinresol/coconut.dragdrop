package coconut.dragdrop;

import why.dragdrop.*;
import tink.s2d.Point;
import tink.state.State;

using tink.CoreApi;

class DraggableModel<Item, Result, Attrs, @:skipCheck Node> implements coconut.data.Model {
	@:constant var type:String;
	@:constant var manager:Manager<Item, Result, Node>;
	@:constant var isDragging:DragSourceContextWithoutIsDragging<Item, Result>->Bool;
	@:constant var canDrag:DragSourceContextWithoutCanDrag<Item, Result>->Bool;
	@:constant var onDragStart:DragSourceContext<Item, Result>->Item;
	@:constant var onDragEnd:DragSourceContext<Item, Result>->Void;
	@:constant var collect:DragSourceContext<Item, Result>->Attrs;
	@:constant var ref:coconut.ui.Ref<Node> = function(node) this.node = node;
	
	@:editable private var node:Node = null;
	
	@:computed var source:Source<Item, Result> = new Source({
		beginDrag: (ctx, id) -> onDragStart(context),
		endDrag: (ctx, id) -> onDragEnd(context),
		canDrag: (ctx, id) -> canDrag(context),
		isDragging: (ctx, id) -> isDragging(context),
	});
	
	@:skipCheck @:computed var registry:Registry<Item, Result> = manager.registry;
	@:computed var sourceId:SourceId = {
		switch ($last) {
			case Some(id): registry.removeSource(id);
			case None:
		}
		registry.addSource(type, source);
	}
	@:computed var context:DragSourceContext<Item, Result> = new DragSourceContext(manager.context, sourceId);
	@:computed var connection:CallbackLink = {
		$last.orNull().cancel();
		if(node == null) null;
		else manager.backend.connectDragSource(sourceId, node, {});
	}
	@:computed var attrs:Attrs = {
		connection; // HACK: this makes it tracked
		collect == null ? null : collect(context);
	}
	
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



@:forward(isDragging, isDraggingSource, isOverTarget, getTargetIds, isSourcePublic, getSourceId, canDragSource, canDropOnTarget, getItemType, getItem, getDropResult, didDrop, getInitialPosition, getInitialSourcePosition, getSourcePosition, getPosition, getDifferenceFromInitialPosition)
abstract DragSourceContextWithoutCanDrag<Item, Result>(DragSourceContext<Item, Result>) from DragSourceContext<Item, Result> {}
@:forward(canDrag, isDraggingSource, isOverTarget, getTargetIds, isSourcePublic, getSourceId, canDragSource, canDropOnTarget, getItemType, getItem, getDropResult, didDrop, getInitialPosition, getInitialSourcePosition, getSourcePosition, getPosition, getDifferenceFromInitialPosition)
abstract DragSourceContextWithoutIsDragging<Item, Result>(DragSourceContext<Item, Result>) from DragSourceContext<Item, Result> {}

@:observable
class DragSourceContext<Item, Result> {
	
	final sourceId:SourceId;
	final context:Context<Item, Result>;
	
	// var isCallingCanDrag = false;
	// var isCallingIsDragging = false;
	
	public function new(context, sourceId) {
		this.context = context;
		this.sourceId = sourceId;
	}
	
	public function canDrag():Bool {
		// if(isCallingCanDrag) throw 'You may not call monitor.canDrag() inside your canDrag() implementation.';

		return
		// Error.tryFinally(() -> {
		// 	isCallingCanDrag = true;
			context.canDragSource(sourceId);
		// }, () -> isCallingCanDrag = false);
	}

	public function isDragging():Bool {
		if (sourceId == null) return false;
		// if(isCallingIsDragging) throw 'You may not call monitor.isDragging() inside your isDragging() implementation.';
		
		return
		// Error.tryFinally(() -> {
		// 	isCallingIsDragging = true;
			context.isDraggingSource(sourceId);
		// }, () -> isCallingIsDragging = false);
	}

	public inline function isDraggingSource(sourceId:SourceId):Bool {
		return context.isDraggingSource(sourceId);
	}

	public inline function isOverTarget(targetId:TargetId, ?options:{shallow:Bool}):Bool {
		return context.isOverTarget(targetId, options);
	}

	public inline function getTargetIds():ImmutableArray<TargetId> {
		return context.getTargetIds();
	}

	public inline function isSourcePublic():Bool {
		return context.isSourcePublic();
	}

	public inline function getSourceId():SourceId {
		return context.getSourceId();
	}

	public inline function canDragSource(sourceId:SourceId):Bool {
		return context.canDragSource(sourceId);
	}

	public inline function canDropOnTarget(targetId:TargetId):Bool {
		return context.canDropOnTarget(targetId);
	}

	public inline function getItemType():SourceType {
		return context.getItemType();
	}

	public inline function getItem():Item {
		return context.getItem();
	}

	public inline function getDropResult():Result {
		return context.getDropResult();
	}

	public inline function didDrop():Bool {
		return context.didDrop();
	}

	public inline function getInitialPosition():Point {
		return context.getInitialPosition();
	}

	public inline function getInitialSourcePosition():Point {
		return context.getInitialSourcePosition();
	}

	public inline function getSourcePosition():Point {
		return context.getSourcePosition();
	}

	public inline function getPosition():Point {
		return context.getPosition();
	}

	public inline function getDifferenceFromInitialPosition():Point {
		return context.getDifferenceFromInitialPosition();
	}
	
}