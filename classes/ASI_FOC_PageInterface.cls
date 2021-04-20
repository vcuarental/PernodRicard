public virtual interface ASI_FOC_PageInterface {

	void setComponentController(String key, ASI_FOC_ComponentInterface cController);
	ASI_FOC_ComponentInterface getComponentController(String key);
}