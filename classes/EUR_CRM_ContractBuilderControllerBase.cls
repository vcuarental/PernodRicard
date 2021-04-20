public with sharing virtual class EUR_CRM_ContractBuilderControllerBase { 
    private EUR_CRM_ContractComponentControllerBase componentController; 
    private Map<String, EUR_CRM_ContractComponentControllerBase> componentControllerMap;

    public virtual EUR_CRM_ContractComponentControllerBase getComponentController() {
        return componentController;
    }

    public virtual void setComponentController(EUR_CRM_ContractComponentControllerBase compController) {
        componentController = compController;
    }
    
    public virtual Map<String, EUR_CRM_ContractComponentControllerBase> getComponentControllerMap(){
        return componentControllerMap;
    }
    
    public virtual void setComponentControllerMap(String key, EUR_CRM_ContractComponentControllerBase compController){
        if (componentControllerMap == null){
            componentControllerMap = new Map<String, EUR_CRM_ContractComponentControllerBase>();
        }
        
        componentControllerMap.put(key, compController);
    }

    public EUR_CRM_ContractBuilderControllerBase getThis() {
        return this;
    }

}