package coconut.dragdrop;

import why.dragdrop.*;
using tink.CoreApi;

class DroppableModel<Item, Result, Attrs, Node> implements coconut.data.Model {
	@:constant var type:String;
	@:constant var manager:Manager<Item, Result, Node>;
	@:constant var canDrop:Item->Bool;
	@:constant var onHover:Item->Void;
	@:constant var onDrop:Item->Result;
	@:constant var collect:Context<Item, Result>->Attrs;
	
	@:editable private var node:Node = null;
	
	@:computed var target:Target<Item, Result> = new Target({
		canDrop: (ctx, id) -> canDrop(ctx.getItem()),
		hover: (ctx, id) -> onHover(ctx.getItem()),
		drop: (ctx, id) -> onDrop(ctx.getItem()),
	});
	
	@:skipCheck @:computed var registry:Registry<Item, Result> = manager.registry;
	@:computed var targetId:TargetId = {
		switch ($last) {
			case Some(id): registry.removeTarget(id);
			case None:
		}
		registry.addTarget([type], target);
	}
	@:computed var connection:CallbackLink = {
		$last.orNull().cancel();
		if(node == null) null;
		else manager.backend.connectDropTarget(targetId, node, {});
	}
	@:computed var attrs:Attrs = {
		connection; // HACK: make it tracked
		collect == null ? null : collect(manager.context);
	}
	
	public function ref(node) 
		this.node = node;
	
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