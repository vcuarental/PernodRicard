({
	render: function(component, helper) {
		var svgns = "http://www.w3.org/2000/svg";
		var xlinkns = "http://www.w3.org/1999/xlink";
		var classname = component.get("v.class");
		var xlinkhref = component.get("v.xlinkHref");
		var ariaHidden = component.get("v.ariaHidden");

		var svgroot = document.createElementNS(svgns, "svg");
		svgroot.setAttribute("class", classname);
		svgroot.setAttribute('aria-hidden', ariaHidden);

		var shape = document.createElementNS(svgns, "use");
		shape.setAttributeNS(xlinkns, "href", xlinkhref);
		svgroot.appendChild(shape);
		return svgroot;
	}
})