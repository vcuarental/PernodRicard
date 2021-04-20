public virtual interface ASI_TnE_PageInterface {

  void setComponentController(ASI_TnE_ComponentInterface cController);
  void setComponentController(String key, ASI_TnE_ComponentInterface cController);
  ASI_TnE_ComponentInterface getComponentController();
  ASI_TnE_ComponentInterface getComponentController(String key);
}