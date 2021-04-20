public virtual interface ASI_CRM_CN_PageInterface {

  void setComponentController(ASI_CRM_CN_ComponentInterface cController);
  void setComponentController(String key, ASI_CRM_CN_ComponentInterface cController);
  ASI_CRM_CN_ComponentInterface getComponentController();
  ASI_CRM_CN_ComponentInterface getComponentController(String key);
}