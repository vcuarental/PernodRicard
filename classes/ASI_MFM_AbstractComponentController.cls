public with sharing virtual class ASI_MFM_AbstractComponentController implements ASI_MFM_ComponentInterface {
	public ASI_MFM_PageInterface pageController {
		get { return this.getPageController(); }
		set { this.setPageController(value); }
	}
	public String componentKey { get { if (componentKey == null) componentKey = 'DEFAULT'; return componentKey; } set; }
	private ASI_MFM_PageInterface privatePageController;
	
	public void setPageController(ASI_MFM_PageInterface pController) {
		if (this.privatePageController == null) {
			this.privatePageController = pController;
			if (this.privatePageController != null)
				this.privatePageController.setComponentController(this.componentKey, this); 
		}
	}
	public ASI_MFM_PageInterface getPageController() {
		return this.privatePageController; 
	}

}