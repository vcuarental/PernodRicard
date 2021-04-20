public with sharing virtual class EUR_CRM_ComponentControllerBase {
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

  public EUR_CRM_PageControllerBase pageController { get; 
    set {
      if (value != null) {
        pageController = value;
        pageController.setComponentController(this);
      }
    }
  }
}