public with sharing virtual class ASI_GiftBox_AbstractComponentController implements ASI_GiftBox_ComponentInterface {
  public ASI_GiftBox_PageInterface pageController {
    get { return this.getPageController(); }
    set { this.setPageController(value); }
  }
  public String componentKey { get { if (componentKey == null) componentKey = 'DEFAULT'; return componentKey; } set; }
  private ASI_GiftBox_PageInterface privatePageController;
  
  public void setPageController(ASI_GiftBox_PageInterface pController) {
    if (this.privatePageController == null) {
      this.privatePageController = pController;
      if (this.privatePageController != null)
        this.privatePageController.setComponentController(this.componentKey, this); 
    }
  }
  public ASI_GiftBox_PageInterface getPageController() {
    return this.privatePageController; 
  }
}