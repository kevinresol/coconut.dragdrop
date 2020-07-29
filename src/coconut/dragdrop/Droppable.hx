package coconut.dragdrop;

import h2d.*;
import why.dragdrop.*;
import tink.state.Observable;
using tink.CoreApi;


class Droppable<Item, Result, Attrs> extends coconut.h2d.View {
	@:attr var model:DroppableModel<Item, Result, Attrs, Heaps.PureInteractive>;
	@:attr var renderChildren:(Heaps.PureInteractive->Void, Attrs)->coconut.h2d.RenderResult;
	
	function render() return renderChildren(model.ref, model.attrs);
}
