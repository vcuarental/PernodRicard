public virtual interface ASI_HK_CRM_PageInterface {

	void setComponentController(ASI_HK_CRM_ComponentInterface cController);
	void setComponentController(String key, ASI_HK_CRM_ComponentInterface cController);
	ASI_HK_CRM_ComponentInterface getComponentController();
	ASI_HK_CRM_ComponentInterface getComponentController(String key);
}