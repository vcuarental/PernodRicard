public with sharing virtual class ASI_CRM_MY_PageControllerBase{
    /*private ASI_CRM_SG_ComponentControllerBase componentController;
    private Map<String, ASI_CRM_SG_ComponentControllerBase>componentControllerMap; //new

    public virtual ASI_CRM_SG_ComponentControllerBase getComponentController() {
        return componentController;
    }
    public virtual void setComponentController(ASI_CRM_SG_ComponentControllerBase compController) {
        componentController = compController;
    }

    //new getter for the hashmap
    public virtual Map<String, ASI_CRM_SG_ComponentControllerBase> getComponentControllerMap(){
        return componentControllerMap;
    }
    //new method for putting value in the hashmap
    public virtual void setComponentControllerMap(String key, ASI_CRM_SG_ComponentControllerBase compController){
        if(componentControllerMap == null)
          componentControllerMap = new Map<String, ASI_CRM_SG_ComponentControllerBase>();
        componentControllerMap.put(key,compController); 
    }
    */
    public ASI_CRM_MY_PageControllerBase getThis() {
        return this;
    }
}