public with sharing virtual class ASI_FOC_AbstractPageController implements ASI_FOC_PageInterface {
	private static String DEF_CC_KEY = 'DEFAULT';
	private Map<String, ASI_FOC_ComponentInterface> componentControllerMap;
	public ASI_FOC_AbstractPageController thisController { get {return this;} set; }
	
	public ASI_FOC_AbstractPageController() {
		this.componentControllerMap = new Map<String, ASI_FOC_ComponentInterface>();
	}
	public void setComponentController(String key, ASI_FOC_ComponentInterface cController) {
		if (key != null && cController != null)
			this.componentControllerMap.put(key, cController);
	}
	public ASI_FOC_ComponentInterface getComponentController(String key) {
		if (key == null) return null;
		return this.componentControllerMap.get(key);
	}
	
}