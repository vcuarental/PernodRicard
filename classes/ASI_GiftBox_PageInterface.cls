public virtual interface ASI_GiftBox_PageInterface {
  void setComponentController(ASI_GiftBox_ComponentInterface cController);
  void setComponentController(String key, ASI_GiftBox_ComponentInterface cController);
  ASI_GiftBox_ComponentInterface getComponentController();
  ASI_GiftBox_ComponentInterface getComponentController(String key);
}