package;

import h2d.*;
import coconut.dragdrop.*;
import why.dragdrop.*;
import why.dragdrop.backend.*;
// import coconut.haxeui.*;
// import coconut.ui.*;
// import Playground.*;

// import haxe.ui.*;
// import haxe.ui.core.*;
// import haxe.ui.components.*;
// import haxe.ui.containers.*;

class Heaps extends hxd.App {
	override function init() {
		
		final manager = new Manager<MyItem, MyResult, Interactive>();
		final context = manager.getMonitor();
		final backend = new HeapsBackend(s2d, context, manager.getActions());
		manager.setBackend(backend);
		
		hxd.Window.getInstance().useScreenPixels = false;
		coconut.ui.Renderer.mount(s2d, '<Dummy manager=${manager}/>');
	}
	static function main() {
		new Heaps();
	}

}

typedef MyItem = {
	final foo:String;
}

typedef MyResult = {
	final bar:String;
}

class Dummy extends coconut.h2d.View {
	@:attr var manager:Manager<MyItem, MyResult, PureInteractive>;
	@:computed var draggable:DraggableModel<MyItem, MyResult, {final x:Int; final y:Int; final item:MyItem;}, PureInteractive> = {
		var last = tink.s2d.Point.xy(0, 0);
		trace('new draggable');
		new DraggableModel({
			type: 'FOO', 
			manager: manager, 
			canDrag: () -> true,
			onDragStart: () -> {foo: 'bar'},
			onDragEnd: ctx -> {
				trace(ctx.getDropResult());
				switch ctx.getSourceClientOffset() {
					case null: // skip
					case v: last = v;
				}
			},
			isDragging: item -> item != null,
			collect: ctx -> {
				final pos = switch ctx.getSourceClientOffset() {
					case null: last;
					case v: last = v;
				}
				{x: Std.int(pos.x), y: Std.int(pos.y), item: ctx.getItem()}
			}
		});
	}
	@:computed var droppable:DroppableModel<MyItem, MyResult, {final isOver:Bool;}, PureInteractive> = {
		var model:DroppableModel<MyItem, MyResult, {final isOver:Bool;}, PureInteractive> = null;
		model = new DroppableModel({
			type: 'FOO', 
			manager: manager, 
			canDrop: item -> true,
			onHover: item -> trace('hover'),
			onDrop: item -> {
				trace('drop');
				{bar: 'baz'}
			},
			collect: ctx -> {
				{isOver: ctx.getTargetIds().contains(model.targetId) && ctx.canDropOnTarget(model.targetId)}
			}
		});
		model;
	}
		
		
	function render() '
		<>
		<Droppable
			model=${droppable}
			renderChildren=${(ref, attrs) -> (
				<Interactive x=${100} y=${100} width=${100} height=${20} backgroundColor=${attrs.isOver ? 0xFFCCCCCC : 0xFF2222FF} onClick=${trace('clicked')} ref=${ref}>
					<Text
						x=${50} 
						y=${2} 
						font=${hxd.res.DefaultFont.get()} 
						text="Target"
						textAlign=${Center}
						textColor=${0}
					/>
				</Interactive>
			)}
		/>
		<Draggable
			model=${draggable}
			renderChildren=${(ref, attrs) -> (
				<Interactive x=${attrs.x} y=${attrs.y} width=${100} height=${20} backgroundColor=${attrs.item == null ? 0xFFCCCCCC : 0xFFFFFF22} onClick=${trace('clicked')} ref=${ref}>
					<Text
						x=${50} 
						y=${2} 
						font=${hxd.res.DefaultFont.get()} 
						text=${'Dragging: ' + (attrs.item == null ? 'false' : attrs.item.foo)}
						textAlign=${Center}
						textColor=${0}
					/>
				</Interactive>
			)}
		/>
		
		
		</>
	';
	
	override function viewWillUnmount() {
		draggable.dispose();
		droppable.dispose();
	}
}

@:observable abstract PureInteractive(Interactive) from Interactive to Interactive {}