/*********************************************************************************
 * Name: ASI_CRM_TW_ComponentControllerBase 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/04/2015       Introv: Twinkle         Cloned from ASI_CRM_SG_ComponentControllerBase 
*********************************************************************************/

public with sharing virtual class ASI_CRM_TW_ComponentControllerBase {
  //the new property
  public String key{ get;
    set{
      if(value != null){
         Key  = value;
         if(pageController != null)
            pageController.setComponentControllerMap(Key, this);
      }
    }
  }

  public ASI_CRM_TW_PageControllerBase pageController { get; 
    set {
      if (value != null) {
        pageController = value;
        pageController.setComponentController(this);
      }
    }
  }
}