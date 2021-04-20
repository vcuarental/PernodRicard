/*********************************************************************************
 * Name: ASI_CRM_TH_ComponentControllerBase 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_ComponentControllerBase 
*********************************************************************************/

public with sharing virtual class ASI_CRM_TH_ComponentControllerBase {
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

  public ASI_CRM_TH_PageControllerBase pageController { get; 
    set {
      if (value != null) {
        pageController = value;
        pageController.setComponentController(this);
      }
    }
  }
}