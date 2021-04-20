public with sharing virtual class ASI_FOC_AbstractComponentController implements ASI_FOC_ComponentInterface {
	public ASI_FOC_PageInterface myPageController {
		get { return this.getPageController(); }
		set { this.setPageController(value); }
	}
	public String myComponentKey { get { if (myComponentKey == null) myComponentKey = 'DEFAULT'; return myComponentKey; } set; }
	private ASI_FOC_PageInterface privatePageController;
	
	public void setPageController(ASI_FOC_PageInterface pController) {
		if (this.privatePageController == null) {
			this.privatePageController = pController;
			this.privatePageController.setComponentController(this.myComponentKey, this);
		}
	}
	public ASI_FOC_PageInterface getPageController() {
		return this.privatePageController;
	}

}