/*********************************************************************************
 * Name: ASI_CRM_TH_PageControllerBase
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_PageControllerBase
*********************************************************************************/

public with sharing virtual class ASI_CRM_TH_PageControllerBase{
    private ASI_CRM_TH_ComponentControllerBase componentController;
    private Map<String, ASI_CRM_TH_ComponentControllerBase>componentControllerMap; //new

    public virtual ASI_CRM_TH_ComponentControllerBase getComponentController() {
        return componentController;
    }
    public virtual void setComponentController(ASI_CRM_TH_ComponentControllerBase compController) {
        componentController = compController;
    }

    //new getter for the hashmap
    public virtual Map<String, ASI_CRM_TH_ComponentControllerBase> getComponentControllerMap(){
        return componentControllerMap;
    }
    //new method for putting value in the hashmap
    public virtual void setComponentControllerMap(String key, ASI_CRM_TH_ComponentControllerBase compController){
        if(componentControllerMap == null)
          componentControllerMap = new Map<String, ASI_CRM_TH_ComponentControllerBase>();
        componentControllerMap.put(key,compController); 
    }

    public ASI_CRM_TH_PageControllerBase getThis() {
        return this;
    }
}