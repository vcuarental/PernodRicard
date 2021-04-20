public without sharing class ASI_HK_CRM_DefaultNewValueController {
    
    private static final Set<String> URL_PARAM_EXCLUDE = new Set<String> {
        'sfdc.override'
        , 'save_new'
    };
    private Schema.SObjectType sObjType;
    private Map<String, String> fieldIdToDefValueMap;
    
    public ASI_HK_CRM_DefaultNewValueController(ApexPages.StandardController stdCon) {
        sObject sObj = stdCon.getRecord();
        this.sObjType = sObj.getSObjectType();
        this.fieldIdToDefValueMap = new Map<String, String>{
            'Name' => '[Auto Assign-Do Not Change]'
        };
    }
    
    public PageReference assignDefaultAndRedirect() {
        PageReference redirectPage = null;
        
        String sObjKeyPrefix = this.sObjType.getDescribe().getKeyPrefix();
        redirectPage = new PageReference('/' + sObjKeyPrefix + '/e');
        Map<String, String> redirectPageParams = redirectPage.getParameters();
        Map<String, String> curPageParams = ApexPages.currentPage().getParameters();
        
        for (String paramName : curPageParams.keySet()) {
            if (!URL_PARAM_EXCLUDE.contains(paramName))
                redirectPageParams.put(paramName, curPageParams.get(paramName));
        }
        
        // Auto fill in PA for JDE Cash Account Order
        ASI_HK_CRM_Field_Prefix__c fpc = ASI_HK_CRM_Field_Prefix__c.getInstance('Setting1');
        
        String PAaccId = curPageParams.get(fpc.SalesOrderNewPAID__c);
        String PAaccName = curPageParams.get(fpc.SalesOrderNewPANameID__c);
        String DAaccId = curPageParams.get(fpc.SalesOrderNewDAID__c);
        String DAaccName = curPageParams.get(fpc.SalesOrderNewDANameID__c);

        
        Map<String, String> otherParams = DefaultNewValue_Map(PAaccId, PAaccName, DAaccId, DAaccName);
        redirectPageParams.putAll(otherParams);
        
        if (this.fieldIdToDefValueMap != null)
            redirectPageParams.putAll(this.fieldIdToDefValueMap);
        redirectPageParams.put('nooverride', '1');
        
        return redirectPage;
    }
    
    
    
    public Map<String, String> DefaultNewValue_Map(String PAaccId, String PAaccName, String DAaccId, String DAaccName)   {
        Map<String, String>  redirectPageParams = new Map<String, String>();
        
        ASI_HK_CRM_Field_Prefix__c fpc = ASI_HK_CRM_Field_Prefix__c.getInstance('Setting1');

        if ( PAaccId != null && PAaccName != null) {
            Account acc = [select id, name, recordType.name from Account where id =: PAaccId];
            if ( acc.recordType.name == 'JDE Salesman Cash Account (HK)' ){
                redirectPageParams.put(fpc.SalesOrderNewDAID__c, PAaccId);
                redirectPageParams.put(fpc.SalesOrderNewDANameID__c, PAaccName);
            }
        }
        
        //Credit Account: Set PA = Credit Acct's Parent 
        else if ( DAaccId != null && DAaccName != null) 
        {
            Account acc = [select id, name, recordType.name, ownerid, Parentid,ASI_LUX_JDE_Parent_Account_Number__c from Account where id =: DAaccId];
            if ( acc.recordType.name == 'Outlet (HK)' )
            {
                if(acc.Parentid == null)
                {
                    redirectPageParams.put(fpc.SalesOrderNewPAID__c, DAaccId );
                    redirectPageParams.put(fpc.SalesOrderNewPANameID__c, DAaccName );   
                }
                else
                {
                    Account New_PA_acc = [select id, name, recordType.name, Parentid from Account where id =: acc.Parentid];
                    redirectPageParams.put(fpc.SalesOrderNewPAID__c, New_PA_acc.id );
                    redirectPageParams.put(fpc.SalesOrderNewPANameID__c, New_PA_acc.name );
                }
            }
            //Potentoal Acct: set PA = Salesman Cash Account
            else if ( acc.recordType.name == 'Potential Account (HK)' || acc.recordType.name == 'Potential Account - Prestige (HK)' )
            {
                if(acc.Parentid == null)
                {
                    Account New_PA_acc = [select id, name, recordType.name, Parentid from Account where ASI_HK_CRM_Inactive__c=false and ownerid =: acc.ownerid and recordType.name='JDE Salesman Cash Account (HK)' and ASI_KOR_Customer_Code__c like 'HK_%' limit 1];
                    redirectPageParams.put(fpc.SalesOrderNewPAID__c, New_PA_acc.id );
                    redirectPageParams.put(fpc.SalesOrderNewPANameID__c, New_PA_acc.name );
                }
                else
                {
                    Account New_PA_acc = [select id, name, recordType.name, Parentid from Account where id =: acc.Parentid];
                    redirectPageParams.put(fpc.SalesOrderNewPAID__c, New_PA_acc.id );
                    redirectPageParams.put(fpc.SalesOrderNewPANameID__c, New_PA_acc.name );
                }

            }
            //Lux Acct: set PA = Salesman Cash Account
            else if ( acc.recordType.name.contains('Luxury Account (HK)') )
            {
                Account New_PA_acc = null;
                if(acc.ASI_LUX_JDE_Parent_Account_Number__c!=null){
                    New_PA_acc = [select id, name, recordType.name, Parentid from Account where accountnumber=: acc.ASI_LUX_JDE_Parent_Account_Number__c and ASI_KOR_Customer_Code__c like 'HK_%'];      
                }else{
                    New_PA_acc = [select id, name, recordType.name, Parentid from Account where ASI_HK_CRM_Inactive__c=false and ownerid =: acc.ownerid and recordType.name='JDE Salesman Cash Account (HK)' and ASI_KOR_Customer_Code__c like 'HK_%' limit 1];
                }
                
                if (New_PA_acc != null){
                    redirectPageParams.put(fpc.SalesOrderNewPAID__c, New_PA_acc.id );
                    redirectPageParams.put(fpc.SalesOrderNewPANameID__c, New_PA_acc.name );
                }                
            }
        }
        return redirectPageParams;
    }
    
}