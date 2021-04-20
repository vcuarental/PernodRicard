public with sharing virtual class ASI_MFM_AbstractComponentController_P implements ASI_MFM_ComponentInterface {
	public ASI_MFM_PageInterface pageControllerValue {
		get { return this.getPageController(); }
		set { this.setPageController(value); }
	}
	public String componentKeyValue { get { if (componentKeyValue == null) componentKeyValue = 'DEFAULT'; return componentKeyValue; } set; }
	private ASI_MFM_PageInterface privatePageController;
	
	public void setPageController(ASI_MFM_PageInterface pController) {
		if (this.privatePageController == null) {
			this.privatePageController = pController;
			if (this.privatePageController != null)
				this.privatePageController.setComponentController(this.componentKeyValue, this); 
		}
	}
	public ASI_MFM_PageInterface getPageController() {
		return this.privatePageController; 
	}

}