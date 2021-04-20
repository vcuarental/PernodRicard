public with sharing virtual class ASI_TnE_AbstractComponentController implements ASI_TnE_ComponentInterface {
  public ASI_TnE_PageInterface pageController {
    get { return this.getPageController(); }
    set { this.setPageController(value); }
  }
  public String componentKey { get { if (componentKey == null) componentKey = 'DEFAULT'; return componentKey; } set; }
  private ASI_TnE_PageInterface privatePageController;
  
  public void setPageController(ASI_TnE_PageInterface pController) {
    if (this.privatePageController == null) {
      this.privatePageController = pController;
      if (this.privatePageController != null)
        this.privatePageController.setComponentController(this.componentKey, this); 
    }
  }
  public ASI_TnE_PageInterface getPageController() {
    return this.privatePageController; 
  }
}