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
		
		final manager = new Manager<MyItem, MyResult, Interactive>(manager -> new HeapsBackend(s2d, manager.context, manager.actions));
		
		hxd.Window.getInstance().useScreenPixels = false;
		var root = new Object(s2d);
		coconut.ui.Renderer.mount(root, '<Dummy manager=${manager}/>');
	}
	static function main() {
		new Heaps();
	}

}

enum abstract Color(Int) to Int {
	var Red = 0xffff0000;
	var Green = 0xff00ff00;
	
	public inline function toString() {
		return this == Red ? 'red' : 'green';
	}
}

typedef MyItem = {
	final color:Color;
}

typedef MyResult = {
	final bar:String;
}

class Drag extends coconut.h2d.View {
	@:skipCheck
	@:attr var manager:Manager<MyItem, MyResult, Interactive>;
	@:attr var item:MyItem;
	@:attr var type:String;
	@:attr var x:Int;
	@:attr var y:Int;
	
	@:skipCheck
	@:computed var draggable:DraggableModel<MyItem, MyResult, {final x:Int; final y:Int; final isDragging:Bool; final item:MyItem; final targetIds:ImmutableArray<TargetId>;}, Interactive> = {
		var last = tink.s2d.Point.xy(x, y);
		new DraggableModel({
			type: type, 
			manager: manager, 
			canDrag: ctx -> true,
			onDragStart: ctx -> {
				trace(item);
				item;
			},
			onDragEnd: ctx -> {
				switch ctx.getSourcePosition() {
					case null: // skip
					case v: last = v;
				}
			},
			isDragging: ctx -> switch ctx.getItem() {
				case null: false;
				case v: v.color == item.color;
			},
			collect: ctx -> {
				
				final pos = switch [ctx.isDragging(), ctx.getSourcePosition()] {
					case [false, _]: last = tink.s2d.Point.xy(x, y);
					case [true, null]: last;
					case [true, v]: last = v;
				}
				{
					x: Std.int(pos.x),
					y: Std.int(pos.y),
					isDragging: ctx.isDragging(),
					targetIds: ctx.getTargetIds(),
					item: ctx.getItem(),
				}
			}
		});
	}
	
	function render() '
		<>
			<Interactive key=${'source' + item.color.toString()} x=${x} y=${y} width=${100} height=${40} backgroundColor=${draggable.attrs.isDragging ? draggable.attrs.item.color : 0xFF555555} ref=${draggable.ref}>
				<Text
					x=${50} 
					y=${2} 
					font=${hxd.res.DefaultFont.get()} 
					text=${switch [draggable.attrs.isDragging, draggable.attrs.targetIds] {
						case [false, _]: item.color.toString() + ': false';
						case [true, ids] if(ids.length == 0): item.color.toString() + ': true';
						case [true, ids]: item.color.toString() + ': true\nOver:' + ids.join(',');
					}}
					textAlign=${Center}
					textColor=${draggable.attrs.isDragging ? 0 : (item.color | 0xFF777777)}
				/>
			</Interactive>
			
	
			<if ${draggable.attrs.isDragging}>
				<Interactive key=${'preview' + item.color.toString()} x=${draggable.attrs.x} y=${draggable.attrs.y} width=${100} height=${40} backgroundColor=${item.color} propagateEvents>
					<Text
						x=${50} 
						y=${2} 
						font=${hxd.res.DefaultFont.get()} 
						text=${'Over:' + draggable.attrs.targetIds.join(',')}
						textAlign=${Center}
						textColor=${draggable.attrs.isDragging ? 0 : (item.color | 0xFF777777)}
					/>
				</Interactive>
			</if>
			
		</>
	';
	
	override function viewWillUnmount() {
		draggable.dispose();
	}
}

class Drop extends coconut.h2d.View {
	@:skipCheck
	@:attr var manager:Manager<MyItem, MyResult, Interactive>;
	@:attr var result:MyResult;
	@:attr var types:ImmutableArray<String>;
	@:attr var x:Int;
	@:attr var y:Int;
	
	@:skipCheck
	@:computed var droppable:DroppableModel<MyItem, MyResult, {final isOver:Bool; final item:MyItem;}, Interactive> =
		new DroppableModel({
			types: types,
			manager: manager,
			canDrop: ctx -> true,
			onHover: ctx -> {},
			onDrop: ctx -> result,
			collect: ctx -> {
				isOver: ctx.isOver(),
				item: ctx.getItem(),
			}
		});
	
	function render() '
		<Interactive key=${'drop' + types.join(',')} x=${x} y=${y} width=${100} height=${100} backgroundColor=${droppable.attrs.isOver ? 0xFF2222FF : 0xFFAAAAAA} onClick=${trace('clicked')} ref=${droppable.ref}>
			<Text
				x=${50} 
				y=${2} 
				font=${hxd.res.DefaultFont.get()} 
				text=${'Hovered: ${droppable.attrs.isOver ? droppable.attrs.item.color.toString() : 'none'}' + '\n\nAccepts:\n' + types.map(v -> v.toLowerCase()).join('\n')}
				textAlign=${Center}
				textColor=${droppable.attrs.isOver ? 0xffffffff : 0}
			/>
		</Interactive>
	';
	
	override function viewWillUnmount() {
		droppable.dispose();
	}
}

class Dummy extends coconut.h2d.View {
	@:skipCheck
	@:attr var manager:Manager<MyItem, MyResult, Interactive>;
		
		
	function render() '
		<>
			<Drop manager=${manager} types=${['RED']} x=${20} y=${200} result=${{bar: 'baz1'}}/>
			<Drop manager=${manager} types=${['GREEN', 'RED']} x=${140} y=${200} result=${{bar: 'baz2'}}/>
			<Drop manager=${manager} types=${['GREEN']} x=${260} y=${200} result=${{bar: 'baz3'}}/>
			<Drag manager=${manager} type="GREEN" x=${80} y=${140} item=${{color: Green}}/>
			<Drag manager=${manager} type="RED" x=${200} y=${140} item=${{color: Red}}/>
		</>
	';
}