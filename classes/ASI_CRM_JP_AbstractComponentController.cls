/*********************************************************************************
 * Name:ASI_CRM_JP_AbstractComponentController 
 * Description: Abstract class essential for the MassCreateAndUpdate Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Conrad          Created
**********************************************************************************/
public with sharing virtual class ASI_CRM_JP_AbstractComponentController implements ASI_CRM_ComponentInterface {
  public ASI_CRM_PageInterface pageController {
    get { return this.getPageController(); }
    set { this.setPageController(value); }
  }
  public String componentKey { get { if (componentKey == null) componentKey = 'DEFAULT'; return componentKey; } set; }
  private ASI_CRM_PageInterface privatePageController;
  
  public void setPageController(ASI_CRM_PageInterface pController) {
    if (this.privatePageController == null) {
      this.privatePageController = pController;
      if (this.privatePageController != null)
        this.privatePageController.setComponentController(this.componentKey, this); 
    }
  }
  public ASI_CRM_PageInterface getPageController() {
    return this.privatePageController; 
  }

}