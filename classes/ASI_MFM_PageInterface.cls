public virtual interface ASI_MFM_PageInterface {

	void setComponentController(ASI_MFM_ComponentInterface cController);
	void setComponentController(String key, ASI_MFM_ComponentInterface cController);
	ASI_MFM_ComponentInterface getComponentController();
	ASI_MFM_ComponentInterface getComponentController(String key);
}