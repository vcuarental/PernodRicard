public with sharing virtual class ASI_KOR_SaveRedirectController {
	
	protected sObject mySObj;
	protected String saveURL;
	protected String sObjPrefix;
	
	public ASI_KOR_SaveRedirectController(ApexPages.StandardController stdController) {
		this(stdController, null);
	}
	
	public ASI_KOR_SaveRedirectController(ApexPages.StandardController stdController, String saveURL) {
		this.mySObj = stdController.getRecord();
		this.sObjPrefix = this.mySObj.getSObjectType().getDescribe().getKeyPrefix();
		this.saveURL = saveURL;
	}
	
	public PageReference redirect() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		params.remove('save_new');
		params.remove('sfdc.override');
		params.put('nooverride', '1');
		params.put('saveURL', saveURL);
		return new PageReference('/' + this.sObjPrefix + '/e?' + paramsToStr(params));
	}
	
	protected void setSaveURL(String theUrl) {
		this.saveURL = theUrl;
	}
	
	protected String paramsToStr(Map<String, String> params) {
		String result = '';
		if (params != null) {
			Set<String> paramKeySet = params.keySet();
			for (String key : paramKeySet) {
				result += '&' + key + '=' + params.get(key);
			}
		}
		if (result.length() < 1)
			return '';
		else
			return result.substring(1);
	}
	
}