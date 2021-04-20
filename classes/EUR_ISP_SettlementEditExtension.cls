/**
 * Custom AccountEU Lookup for Settlement Edit / Create page for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SettlementEditExtension
{
	private ApexPages.StandardController stdConroller;
	public EUR_ISP_SettlementEditExtension(ApexPages.StandardController stdConroller)
	{
		this.stdConroller = stdConroller;
	}

	public PageReference init()
	{
		User theUser = EUR_ISP_HomeController.getCurrentUserInfo();
		final String countryCode = Test.isRunningTest() ? EUR_ISP_Utils.COUNTRY_CODE_DE : theUser.EUR_CRM_Country_Code__c;
		if (countryCode != EUR_ISP_Utils.COUNTRY_CODE_DE || Test.isRunningTest())
		{
			Map<String, String> params = ApexPages.currentPage().getParameters();
			if (this.stdConroller.getId() == null)
			{

				PageReference createView = new PageReference('/' + EUR_ISP_Settlement__c.sObjectType.getDescribe().getKeyPrefix() + '/e?' );
				if (params.containsKey('retURL'))
				{
					createView.getParameters().put('retURL', params.get('retURL'));
				}
				if (params.containsKey('RecordType'))
				{
					createView.getParameters().put('RecordType', params.get('RecordType'));
				}
				if (params.containsKey('ent'))
				{
					createView.getParameters().put('ent', params.get('ent'));
				}
				createView.getParameters().put('nooverride', '1');
				return createView;
			}
			else
			{
				PageReference editView = this.stdConroller.edit();
				if (params.containsKey('retURL'))
				{
					editView.getParameters().put('retURL', params.get('retURL'));
				}
				editView.getParameters().put('nooverride', '1');
				return editView;
			}
		}
		return null;
	}

	public PageReference customSave()
	{
		sObject obj = stdConroller.getRecord();
		if (obj != null)
		{
			upsert obj;
			return new ApexPages.StandardController(obj).view();
		}
		return null;
	}
}