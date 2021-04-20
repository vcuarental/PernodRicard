public with sharing virtual class ASI_CRM_CN_AbstractComponentController implements ASI_CRM_CN_ComponentInterface {
  public ASI_CRM_CN_PageInterface pageController {
    get { return this.getPageController(); }
    set { this.setPageController(value); }
  }
  public String componentKey { get { if (componentKey == null) componentKey = 'DEFAULT'; return componentKey; } set; }
  private ASI_CRM_CN_PageInterface privatePageController;
  
  public void setPageController(ASI_CRM_CN_PageInterface pController) {
    if (this.privatePageController == null) {
      this.privatePageController = pController;
      if (this.privatePageController != null)
        this.privatePageController.setComponentController(this.componentKey, this); 
    }
  }
  public ASI_CRM_CN_PageInterface getPageController() {
    return this.privatePageController; 
  }
}