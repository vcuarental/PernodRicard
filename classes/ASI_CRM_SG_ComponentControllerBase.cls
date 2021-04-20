public with sharing virtual class ASI_CRM_SG_ComponentControllerBase {
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

  public ASI_CRM_SG_PageControllerBase pageController { get; 
    set {
      if (value != null) {
        pageController = value;
        pageController.setComponentController(this);
      }
    }
  }
}