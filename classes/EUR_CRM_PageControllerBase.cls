public with sharing virtual class EUR_CRM_PageControllerBase{
    private EUR_CRM_ComponentControllerBase componentController;
    private Map<String, EUR_CRM_ComponentControllerBase>componentControllerMap; //new

    public virtual EUR_CRM_ComponentControllerBase getComponentController() {
        return componentController;
    }
    public virtual void setComponentController(EUR_CRM_ComponentControllerBase compController) {
        componentController = compController;
    }

    //new getter for the hashmap
    public virtual Map<String, EUR_CRM_ComponentControllerBase> getComponentControllerMap(){
        return componentControllerMap;
    }
    //new method for putting value in the hashmap
    public virtual void setComponentControllerMap(String key, EUR_CRM_ComponentControllerBase compController){
        if(componentControllerMap == null)
          componentControllerMap = new Map<String, EUR_CRM_ComponentControllerBase>();
        componentControllerMap.put(key,compController); 
    }

    public EUR_CRM_PageControllerBase getThis() {
        return this;
    }
}