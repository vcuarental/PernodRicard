public virtual interface ASI_CRM_PageInterface {

  void setComponentController(ASI_CRM_ComponentInterface cController);
  void setComponentController(String key, ASI_CRM_ComponentInterface cController);
  ASI_CRM_ComponentInterface getComponentController();
  ASI_CRM_ComponentInterface getComponentController(String key);
}