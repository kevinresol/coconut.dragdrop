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
		coconut.ui.Renderer.mount(
			s2d,
			'<Dummy manager=${manager}/>'
		);
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
	@:skipCheck @:attr var manager:Manager<MyItem, MyResult, Interactive>;
	function render() '
		<Draggable
			manager=${manager}
			type="FOO"
			canDrag=${() -> true}
			onDragStart=${() -> {foo: 'bar'}}
			onDragEnd=${() -> trace('end')}
			isDragging=${item -> item != null}
		/>
	';
}