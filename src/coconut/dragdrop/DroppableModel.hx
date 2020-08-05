package coconut.dragdrop;

import why.dragdrop.*;
import tink.s2d.Point;
import tink.state.State;

using tink.CoreApi;

class DroppableModel<Item, Result, Attrs, @:skipCheck Node> implements coconut.data.Model {
	@:constant var types:ImmutableArray<String>;
	@:constant var manager:Manager<Item, Result, Node>;
	@:constant var canDrop:DropTargetContextWithoutCanDrop<Item, Result>->Bool;
	@:constant var onHover:DropTargetContext<Item, Result>->Void;
	@:constant var onDrop:DropTargetContext<Item, Result>->Result;
	@:constant var collect:DropTargetContext<Item, Result>->Attrs;
	@:constant var ref:coconut.ui.Ref<Node> = function(node) this.node = node;
	
	@:editable private var node:Node = null;
	
	@:computed var target:Target<Item, Result> = new Target({
		canDrop: (ctx, id) -> canDrop(context),
		hover: (ctx, id) -> onHover(context),
		drop: (ctx, id) -> onDrop(context),
	});
	
	@:skipCheck @:computed var registry:Registry<Item, Result> = manager.registry;
	@:computed var targetId:TargetId = {
		switch ($last) {
			case Some(id): registry.removeTarget(id);
			case None:
		}
		registry.addTarget(types, target);
	}
	@:computed var context:DropTargetContext<Item, Result> = new DropTargetContext(manager.context, targetId);
	@:computed var connection:CallbackLink = {
		$last.orNull().cancel();
		if(node == null) null;
		else manager.backend.connectDropTarget(targetId, node, {});
	}
	@:computed var attrs:Attrs = {
		connection; // HACK: this makes it tracked
		collect == null ? null : collect(context);
	}
	
	public function dispose() {
		connection.cancel();
		registry.removeTarget(targetId);
	}
}

@:structInit
private class Target<Item, Result> implements DropTarget<Item, Result> {
	final _canDrop:(ctx:Context<Item, Result>, targetId:TargetId)->Bool;
	final _hover:(ctx:Context<Item, Result>, targetId:TargetId)->Void;
	final _drop:(ctx:Context<Item, Result>, targetId:TargetId)->Result;
	
	public inline function new(o) {
		_canDrop = o.canDrop;
		_hover = o.hover;
		_drop = o.drop;
	}
	
	
	public function canDrop(ctx:Context<Item, Result>, targetId:TargetId):Bool {
		return _canDrop(ctx, targetId);
	}
	public function hover(ctx:Context<Item, Result>, targetId:TargetId):Void {
		_hover(ctx, targetId);
	}
	public function drop(ctx:Context<Item, Result>, targetId:TargetId):Result {
		return _drop(ctx, targetId);
	}
}

@:forward(isOver, getItemType, getItem, getDropResult, didDrop, getInitialPosition, getInitialSourcePosition, getSourcePosition, getPosition, getDifferenceFromInitialPosition)
abstract DropTargetContextWithoutCanDrop<Item, Result>(DropTargetContext<Item, Result>) from DropTargetContext<Item, Result> {}

@:observable
class DropTargetContext<Item, Result> {
	
	final targetId:TargetId;
	final context:Context<Item, Result>;
	
	// var isCallingCanDrop = false;
	
	public function new(context, targetId) {
		this.context = context;
		this.targetId = targetId;
	}
	
	public function canDrop():Bool {
		// if(isCallingCanDrop) throw 'You may not call monitor.canDrop() inside your canDrop() implementation.';

		return
		// Error.tryFinally(() -> {
		// 	isCallingCanDrop = true;
			context.canDropOnTarget(targetId);
		// }, () -> isCallingCanDrop = false);
	}

	public inline function isOver(?options:{shallow:Bool}):Bool {
		return if (targetId == null) false else context.isOverTarget(targetId, options);
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