/*
====================================================================
Usage: Use it to convert the lookup field to the pickList

Step1: First need to initialize the class objectPickListHelper and pass the object parameter you would like to retrieve
Example: objectPickListHelper helper1 = new objectPickListHelper('Account');

Step2: Get the retrived list by helper1.pickList; 
====================================================================
*/
public class ASI_MFM_ObjectPickListHelper{

    public Map<String,String> chosedMap{get;set;} 
    public List<selectOption> pickList{get;set;}
    public List<sObject> existingSObjList{get;set;}
    public List<sObject> existingSubSObjList{get;set;}
    public String sObjInputTypeStr { get; set;}
    public String sObjInputFieldStr { get; set; }
    public String sObjSubInputTypeStr{ get; set;}
    public String sObjSubInputFieldStr { get; set; }
    public String sObjectIDPlan { get; set; }
    public boolean isPlanItem { get; set; }
    public string recLimit {get;set;}
    public string whereClause {get;set;}
    public string sObjInputRelatedFieldStr { get; set; }
    /* add filter and record limit to picklist values
        Michael Yip(Introv) 19Dec2013
    */
    public ASI_MFM_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String recLimit, String whereClause){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputFieldStr= sObjInputFieldStr;
        this.recLimit = recLimit;
        this.whereClause = whereClause;
        isPlanItem = false;
        System.debug('flk1' + sObjInputTypeStr + '|flk2' + sObjInputFieldStr);
        init(); 
    }
    
     /* add filter and record limit to picklist values
        Steve Wan(Introv) 20Dec2013
    */
    public ASI_MFM_ObjectPickListHelper(String sObjInputTypeStr, String whereClause, String recLimit, String sObjInputRelatedFieldStr, boolean isSubItem){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputRelatedFieldStr= sObjInputRelatedFieldStr;
        this.recLimit = recLimit;
        this.whereClause = whereClause;
        isPlanItem = false;
        System.debug('flk1' + sObjInputTypeStr);
        System.debug('flk2' + sObjInputFieldStr);
        System.debug('flk2.1' + sObjInputRelatedFieldStr);
        initForSubItem(); 
    }
    public ASI_MFM_ObjectPickListHelper(String sObjInputTypeStr, String whereClause, String recLimit, String sObjInputRelatedFieldStr, String sObjSubInputTypeStr, String sObjSubInputFieldStr,  boolean isMultiItem){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputRelatedFieldStr= sObjInputRelatedFieldStr;
        this.sObjSubInputTypeStr= sObjSubInputTypeStr;
        this.sObjSubInputFieldStr= sObjSubInputFieldStr;
        this.recLimit = recLimit;
        this.whereClause = whereClause;
        isPlanItem = false;
        System.debug('flk1' + sObjInputTypeStr);
        System.debug('flk2' + sObjInputFieldStr);
        System.debug('flk2.1' + sObjInputRelatedFieldStr);
        System.debug('flk2.2' + sObjSubInputTypeStr);
        System.debug('flk2.3' + sObjSubInputFieldStr);
        initForMultiItem(); 
    } 
    
    public ASI_MFM_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputFieldStr= sObjInputFieldStr;
        isPlanItem = false;
        System.debug('flk1' + sObjInputTypeStr);
        System.debug('flk2' + sObjInputFieldStr);
        init(); 
    }
    
    //Override the default constructor for the special case: sObjInputTypeStr = ASI_MFM_Plan_Line_Item__c AND sObjInputFieldStr = ASI_MFM_A_C_Code__c
    public ASI_MFM_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String sObjectIDPlan){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputFieldStr= sObjInputFieldStr;
        this.sObjectIDPlan = sObjectIDPlan;
        isPlanItem = true;
        System.debug('flk1' + sObjInputTypeStr + '|flk2' + sObjInputFieldStr);
        init();
    }
    
    private void init(){    
        System.debug('flk3' + sObjInputTypeStr + '|flk4' + sObjInputFieldStr);
        Schema.sObjectType sobjType = Schema.getGlobalDescribe().get(sObjInputTypeStr);
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult F = sObjFieldMap.get(sObjInputFieldStr).getDescribe();    
    
        if(!F.isNamePointing()){
            List<Schema.sobjectType> sobjTypeList = F.getReferenceTo();
            String retObject = sobjTypeList[0].getDescribe().getName();
            String queryStr = '';
            
            if (isPlanItem)
            {
                String planId = sObjectIDPlan.replace('ASI_MFM_Plan__c','');
                String planQuery = 'SELECT id, ASI_MFM_Prefix__c FROM ASI_MFM_Plan__c WHERE ID' + planId;
                System.debug('flk20131003 planquery ' + planQuery);
                ASI_MFM_Plan__c currentPlan = Database.query(planQuery);
                String planPrefixId =  currentPlan.ASI_MFM_Prefix__c;
                String planTypeQuery = 'SELECT Id, Plan_Type__c FROM ASI_MFM_Prefix__c WHERE ID =: planPrefixId';
                System.debug('flk20131003 planTypeQuery ' + planTypeQuery);
                ASI_MFM_Prefix__c currentPrefix = Database.query(planTypeQuery);
                String planType = currentPrefix.Plan_Type__c;
                System.debug('flk20131003 plantype' + planType);
                //                                            0            1           2                3            4              5             6 
                List<String> APTreeMap = new list<String> {'TOTAL A&P','Total A&D','A&D+A&P','TOTAL A&P+DISCOUNT','Legal Contract', 'Capex' , 'Structure Cost' };
                //                                                    0        1        2           3         4          5            6             7           8              9           10
                List<String> ReportCategoryMap = new list<String> {'Media','Trade','Consumer','A&P Accrual','A&D', 'A&D Accrual','Legal Contract','IT Capex','Other Opex' , 'IT Opex' ,'HR Opex' };
                //                                                                0
                List<String> MarketingCategoryMap = new list<String> {'Presentation/Promoter'};
                
                if (planType.equals('Marketing A&P Plan'))
                {
                     String Query1 = APTreeMap.get(0);
                     String Query2 = ReportCategoryMap.get(0);
                     String Query3 = ReportCategoryMap.get(2);
                     String Query4 = ReportCategoryMap.get(3);
                     String Query5 = MarketingCategoryMap.get(0);
                     queryStr = 'SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE ASI_MFM_A_and_P_Tree__c = \''+Query1+ 
                     '\' AND (ASI_MFM_Reporting_Category__c = \''+Query2+'\' OR ASI_MFM_Reporting_Category__c = \''+Query3+
                     '\' OR ASI_MFM_Reporting_Category__c = \''+Query4+'\') AND ASI_MFM_Marketing_Category__c != \''+Query5+'\' order by Name';
                }
                else if (planType.equals('Trade A&P Plan'))
                {
                    String Query1 = APTreeMap.get(0);
                    String Query2 = ReportCategoryMap.get(1);
                    queryStr = 'SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE ASI_MFM_A_and_P_Tree__c = \''+Query1+
                    '\' AND ASI_MFM_Reporting_Category__c = \''+Query2+'\' order by Name';
                }
                else if (planType.equals('BC Type Plan'))
                {
                    String Query1 = APTreeMap.get(0);
                    String Query2 = ReportCategoryMap.get(2);
                    String Query3 = MarketingCategoryMap.get(0);
                    System.debug('flk9001 Query1 ' + Query1 + ' Query2 ' + Query2 + ' Query3 ' + Query3);
                    queryStr = 'SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE ASI_MFM_A_and_P_Tree__c =\''+ Query1 +
                    '\' AND ASI_MFM_Reporting_Category__c = \''+Query2+'\' AND ASI_MFM_Marketing_Category__c = \''+Query3+'\' order by Name';
                }
                else if (planType.equals('Allowance & Discount Spending Form'))
                {
                    String Query1 = APTreeMap.get(1);
                    String Query2 = ReportCategoryMap.get(4);
                    String Query3 = ReportCategoryMap.get(5);
                    queryStr = 'SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE ASI_MFM_A_and_P_Tree__c = \''+Query1 + 
                    '\' AND (ASI_MFM_Reporting_Category__c = \''+Query2+'\' OR ASI_MFM_Reporting_Category__c = \''+Query3+'\') order by Name';
                }else if (planType.equals('Trade A&P and A&D Plan')){
                    String Query = APTreeMap.get(0);
                    String Query1 = APTreeMap.get(1);
                    String Query2 = ReportCategoryMap.get(1);
                    String Query3 = ReportCategoryMap.get(4);
                    queryStr = 'SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE (ASI_MFM_A_and_P_Tree__c = \'' + Query + '\' OR ASI_MFM_A_and_P_Tree__c = \''+Query1 + 
                    '\') AND (ASI_MFM_Reporting_Category__c = \''+Query2+'\' OR ASI_MFM_Reporting_Category__c like \'%'+Query3+'%\') order by Name';                    
                }
                //Added by PRC Support for Legal Contract CR 28-1-2016
                else if (planType.equals('Legal Contract')){
                     String Query1 = APTreeMap.get(4);
                    String Query2 = ReportCategoryMap.get(6);
                    queryStr = 'SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE ASI_MFM_A_and_P_Tree__c = \''+Query1+
                    '\' AND ASI_MFM_Reporting_Category__c = \''+Query2+'\' order by Name';                  
                }  else if (planType.equals('Mixed Plan')){
                    String Query = APTreeMap.get(0);
                    String Query1 = APTreeMap.get(1);
                    queryStr = 'SELECT id, Name FROM '+ retObject +'  WHERE (ASI_MFM_A_and_P_Tree__c = \'' + Query + '\' OR ASI_MFM_A_and_P_Tree__c = \''+Query1 + '\')  AND  ASI_MFM_Reporting_Category__c != NULL  order by Name';
                }
                //End - Legal Contract CR 28-1-2016
                //TW Structure Cost
                
                else if (planType.equals('Structure Cost')){
                    String Query = APTreeMap.get(5);
                    String Query1 = APTreeMap.get(6);
                    queryStr = 'SELECT id, Name FROM '+ retObject +'  WHERE (ASI_MFM_A_and_P_Tree__c = \'' + Query + '\' OR ASI_MFM_A_and_P_Tree__c = \''+Query1 + '\')  order by Name';
                }else{
                    system.debug('Test !!!!');
                    queryStr = 'SELECT id, Name FROM '+ retObject +' order by Name';
                }
            }
             
            else{
                /* add filter and record limit to picklist values
                    Michael Yip(Introv) 19Dec2013
                */
                queryStr = 'SELECT id, Name FROM '+ retObject;
                if(whereClause != '' && whereClause != null){
                    queryStr += ' where ' + whereClause +' ';
                }
                queryStr += ' order by Name';
                if(recLimit != '' && recLimit != null){
                    queryStr += ' limit ' + recLimit +' ';
                }
            }

            System.debug('flk6 ' + retObject + '|flk7 ' + queryStr);
            // Modified by Michael Yip (Introv) 26May2014
            if(test.isrunningtest() && !queryStr.contains('limit')){
                queryStr += ' limit 10';
            }   
            pickList = new List<selectOption>();
            existingSObjList = Database.query(queryStr);
            pickList.add(new SelectOption('',''));
                    
            for(sObject sobj: existingSObjList ){
                Object nameValue= sobj.get('Name');
                Object idValue = sobj.get('Id');
                //System.debug('abc2' + nameValue );
                //System.debug('abc' + sobj.getSObjectType());
                //System.debug('abc' + sobj.getSObjectField('Name'));
                if(picklist.size()<1000)
                    pickList.add(new SelectOption(String.valueof(idValue),String.valueof(nameValue)));
            }
        }
    }    
    
    private void initForSubItem(){    
        System.debug('flk3' + sObjInputTypeStr + '|flk4' + sObjInputFieldStr);
        String queryStr = '';
        
        queryStr = 'SELECT '+ sObjInputRelatedFieldStr+'.id, '+ sObjInputRelatedFieldStr+'.Name FROM '+ sObjInputTypeStr;
        if(whereClause != '' && whereClause != null){
            queryStr += ' where ' + whereClause +' ';
        }
        queryStr += ' order by Name';
        if(recLimit != '' && recLimit != null){
            queryStr += ' limit ' + recLimit +' ';
        }
        
        System.debug('flk7 ' + queryStr);    
        pickList = new List<selectOption>();
        existingSObjList = Database.query(queryStr);
        pickList.add(new SelectOption('',''));
                
        for(sObject sobj: existingSObjList ){
            sObject relatedObj = sobj.getSObject(sObjInputRelatedFieldStr);
            if (relatedObj != null)
            {
                Object nameValue= relatedObj.get('Name');
                Object idValue = relatedObj.get('Id');
                System.debug('nameValue' + nameValue + '|Sobj.getSObjectType' + sobj.getSObjectType());
                pickList.add(new SelectOption(String.valueof(idValue),String.valueof(nameValue)));
            }
        }
    }  
     private void initForMultiItem(){    
        System.debug('flk2' + sObjInputRelatedFieldStr); //ASI_MFM_PP_Category__r
        System.debug('flk3' + sObjInputTypeStr); //ASI_MFM_Plan__c
        System.debug('flk4' + sObjInputFieldStr); //---
        System.debug('flk5' + sObjSubInputTypeStr); //ASI_MFM_PP_Category_A_C__c 
        System.debug('flk6' + sObjSubInputFieldStr); //ASI_MFM_A_C_Code__r
        
        String queryStr = '';
        
        queryStr = 'SELECT '+ sObjInputRelatedFieldStr+'.id, '+ sObjInputRelatedFieldStr+'.Name FROM '+ sObjInputTypeStr;
        if(whereClause != '' && whereClause != null){
            queryStr += ' where ' + whereClause +' ';
        }
        queryStr += ' order by Name';
        if(recLimit != '' && recLimit != null){
            queryStr += ' limit ' + recLimit +' ';
        }
        
        System.debug('flk7 ' + queryStr);    
        pickList = new List<selectOption>();
        existingSObjList = Database.query(queryStr);
        pickList.add(new SelectOption('',''));
                
        for(sObject sobj: existingSObjList ){
            sObject relatedObj = sobj.getSObject(sObjInputRelatedFieldStr);
            if (relatedObj != null)
            {
                Object nameValue= relatedObj.get('Name');
                Object idValue = relatedObj.get('Id');
                System.debug('abc2' + nameValue + '|abc' + sobj.getSObjectType());
                //Sub Query
                String subQueryStr = '';
                subQueryStr = 'SELECT '+ sObjSubInputFieldStr+'.id, '+ sObjSubInputFieldStr+'.Name FROM '+ sObjSubInputTypeStr;
                subQueryStr += ' where ' + sObjInputRelatedFieldStr+'.id = \'' + String.valueof(idValue) + '\'';
                System.debug('flk8 ' + subQueryStr );    
                existingSubSObjList = Database.query(subQueryStr );
               
                for(sObject subSobj: existingSubSObjList ){
                    sObject relatedSubObj = subSobj.getSObject(sObjSubInputFieldStr);
                    if (relatedSubObj != null)
                    {
                        Object subNameValue= relatedSubObj .get('Name');
                        Object subIdValue = relatedSubObj .get('Id');
                        System.debug('abc3' + subNameValue + '|abc4' + subSobj.getSObjectType());
                        pickList.add(new SelectOption(String.valueof(subIdValue ),String.valueof(subNameValue)));
                    }
                }
            }
        }
    }   
}