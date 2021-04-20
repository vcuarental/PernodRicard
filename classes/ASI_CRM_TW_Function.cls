/*********************************************************************************
* Project : TW CRM Offtake upload system
* Test class : ASI_CRM_TW_Function_Test
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 08/12/2020       PRA COE               Created

*********************************************************************************/

public class ASI_CRM_TW_Function{
    public class CRM_TW_Exception extends Exception {}
    
    
    //    0                1             2           3           4           5         6        7         8          9           10     11         12                    
    // Action Type ;Action Code;	From Code ; From Name	;To Code	;To Name	;Date	;SKU Code	;SKU WS	;SKU Name WS;	Qty	;Commit no;	Remark
    
    public static List<ASI_TH_CRM_Actual_Offtake__c>  ConvertUploadLinetoAO(List<String> fileLines , String UploadLogId , string ChannelStr){
        
        List<String> upsertList  = new List<String>();
        Set<String> ActionTypeset = new Set<String>{'INV','STK','BAL','ADJ','BRW','CSN','FOC','PRK'};
            
            List<ASI_TH_CRM_Actual_Offtake__c> resultAOList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        List<String> SuccessLines  = new List<String>();
        List<String> FailedLines  = new List<String>();
        Set<String> AccCodeSet = new Set<String> ();
        Set<String> CustAccCodeSet = new Set<String> ();
        
        
        Set<String> SKUCodeSet = new Set<String> ();
        Set<String> SKUOutSet = new Set<String> ();
        Map<string,account> AccountMap = new Map<string,account>();
        //Map<string,ASI_CRM_AccountsAdditionalField__c> CustomerMap = new Map<string,ASI_CRM_AccountsAdditionalField__c>();
        Map<string,ASI_MFM_SKU_Code__c> SKUMap = new Map<string,ASI_MFM_SKU_Code__c>();
        Map<string,ASI_CRM_SKU_Mapping__c> SKUOutMap = new Map<string,ASI_CRM_SKU_Mapping__c>();
        Map<string,ASI_CRM_Customer_Mapping__c> CustMaping = new Map<string,ASI_CRM_Customer_Mapping__c>();
        Map<string,ASI_CRM_Customer_Mapping__c> OfftakeCustomerMap = new Map<string,ASI_CRM_Customer_Mapping__c>();
        
        Map<string,ASI_TH_CRM_Actual_Offtake__c> OfftakeMap = new Map<string,ASI_TH_CRM_Actual_Offtake__c>(); // for upsert
        Map<string,ASI_TH_CRM_Actual_Offtake__c> oldOfftakeMap = new Map<string,ASI_TH_CRM_Actual_Offtake__c>();
        set<string> OfftakeKeySet = new set<string>();
        
        
        // checking previous status
        ASI_MFM_Mass_Upload_Log__c uploadLog = [select id,ASI_CRM_File_Name__c,ASI_MFM_Status__c,ASI_MFM_Configuration__c,ASI_CRM_Number_of_Failed_Records__c from ASI_MFM_Mass_Upload_Log__c where id = :UploadLogId limit 1 ];
        ASI_CRM_TW_Settings__c  TWSettings= ASI_CRM_TW_Settings__c.getInstance();
        
        
        //looping 1: prepare data
        for (String line : fileLines) {
            if (!String.isEmpty(line)) {
                List<String> values = line.split(',');
                if(values[2]!=null){
                    AccCodeSet.add(values[2].trim());
                }
                if(values[4]!=null){
                    AccCodeSet.add(values[4].trim());
                }
                if(values[7]!=null){
                    string tempstr = values[7].trim().replaceAll('[^a-zA-Z0-9\\s+]', '');
                    tempstr = tempstr.replaceAll( '\\s+', '');
                    SKUCodeSet.add(tempstr);
                }
                if(values[8]!=null){
                    SKUOutSet.add(values[8].trim());
                }
            }
        }
        
        for(Account acc : [select id,ASI_HK_CRM_JDE_Account_Number__c,ASI_HK_CRM_Inactive__c from Account where ASI_HK_CRM_JDE_Account_Number__c in : AccCodeSet and recordType.developerName like '%TW%' and ASI_HK_CRM_JDE_Account_Number__c!=null]){
            AccountMap.put(acc.ASI_HK_CRM_JDE_Account_Number__c,  acc);
        }
        
        for(ASI_CRM_Customer_Mapping__c cusmap: [select id,ASI_CRM_Mapping_Cust_No__c,ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_Inactive__c,ASI_CRM_Offtake_Customer_No__c,ASI_CRM_JDE_Cust_No__c,ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_JDE_Account_Number__c,ASI_CRM_JDE_Cust_No__r.ASI_MFM_Customer_Supplier_Number__c from ASI_CRM_Customer_Mapping__c 
                                                 where recordType.Name ='TW Customer Mapping Detail' and ASI_CRM_Offtake_Customer_No__c in : AccCodeSet and ASI_CRM_Inactive__c = false and ASI_CRM_Mapping_Cust_No__c!=null ])
        {
            string keystr = cusmap.ASI_CRM_Mapping_Cust_No__c + cusmap.ASI_CRM_Offtake_Customer_No__c;
            OfftakeCustomerMap.put(keystr,cusmap);
            CustMaping.put(cusmap.ASI_CRM_Offtake_Customer_No__c,  cusmap);
            CustAccCodeSet.add(cusmap.ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_JDE_Account_Number__c);
        }
        CustAccCodeSet.addAll(AccCodeSet);

        
        for(ASI_MFM_SKU_Code__c sku : [select id,ASI_MFM_SKU_Code__c,ASI_MFM_Sub_brand__c,ASI_MFM_Item_Group__c from ASI_MFM_SKU_Code__c where ASI_MFM_SKU_Code__c in : SKUCodeSet AND RecordType.developerName='ASI_MFM_TW_SKU_Code' ]){ //
            SKUMap.put(sku.ASI_MFM_SKU_Code__c,  sku);
        }
        for(ASI_CRM_SKU_Mapping__c  skum : [select id,ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c,ASI_CRM_SKU__c,ASI_CRM_Account__c,ASI_CRM_Offtake_Product__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,ASI_CRM_SKU__r.ASI_MFM_Item_Group__c,ASI_CRM_SKU_Mapping_Header__c,ASI_CRM_SKU_Mapping_Header__r.ASI_CRM_Account__r.ASI_HK_CRM_JDE_Account_Number__c, ASI_CRM_SKU_Mapping_Header__r.ASI_CRM_Account__r.ASI_MFM_Customer_Supplier_Number__c 
                                            from ASI_CRM_SKU_Mapping__c 
                                            where ASI_CRM_Offtake_Product__c in: SKUOutSet and  recordType.Name ='ASI CRM TW SKU Mapping Detail' and ASI_CRM_SKU__c !=null and ASI_CRM_SKU_Mapping_Header__c!=null  and ASI_CRM_Offtake_Product__c!=null])
        {
            string keystr =skum.ASI_CRM_Offtake_Product__c;
            if(skum.ASI_CRM_SKU_Mapping_Header__r.ASI_CRM_Account__r.ASI_MFM_Customer_Supplier_Number__c !=null){
                keystr +=skum.ASI_CRM_SKU_Mapping_Header__r.ASI_CRM_Account__r.ASI_MFM_Customer_Supplier_Number__c;
            }else if(skum.ASI_CRM_SKU_Mapping_Header__r.ASI_CRM_Account__r.ASI_HK_CRM_JDE_Account_Number__c!=null){
                keystr +=skum.ASI_CRM_SKU_Mapping_Header__r.ASI_CRM_Account__r.ASI_HK_CRM_JDE_Account_Number__c;
            }
            SKUOutMap.put(keystr,skum);
        }
        
        
        //validation checking
        for (String line : fileLines) {
            Boolean HasError = false;
            String Msg ='';
            if (!String.isEmpty(line)) { // possible empty line
                system.debug('*****line****');
                system.debug(line);
                List<String> values = line.removeEnd('\n').split(',');
                ASI_TH_CRM_Actual_Offtake__c ao = new ASI_TH_CRM_Actual_Offtake__c();
                
                ao.ASI_CRM_Action_Type__c = values[0] != null ? values[0].trim(): null; 
                ao.ASI_CRM_From_Code_Upload__c  = values[2] != null ? values[2].trim(): null;
                ao.ASI_CRM_To_Code_Upload__c= values[4] != null ? values[4].trim(): null;
                
                ao.ASI_TH_CRM_Offtake_G_L_Date__c =  values[6] != null ? convertString2Date(values[6].trim()): null; //  like 20200731
                ao.ASI_CRM_SKU_Code_Uploaded__c = values[7] != null ? values[7].trim(): null;
                ao.ASI_CRM_SG_Debit_Note_Number__c = values[8] != null ? values[8].trim(): null; // outside sku code
                
                ao.ASI_CRM_Channel__c = ChannelStr;
                //.isNumeric()
                if(values[10] != null ){
                    string numstr = values[10].trim();
                    try{
                        ao.ASI_TH_CRM_Quantity__c =Integer.valueof(numstr);
                    } catch (Exception e) {
                        HasError=true;
                        Msg+=values[10] +'Quantity Type is not allowed';
                    }

                }else{
                    ao.ASI_TH_CRM_Quantity__c = 0;
                }
                // remove special characters from the string in Apex
                ao.ASI_CRM_Action_Type__c = ao.ASI_CRM_Action_Type__c.replaceAll('[^a-zA-Z0-9\\s+]', '');
                ao.ASI_CRM_SKU_Code_Uploaded__c =ao.ASI_CRM_SKU_Code_Uploaded__c.replaceAll('[^a-zA-Z0-9\\s+]', '');
                ao.ASI_CRM_SKU_Code_Uploaded__c = ao.ASI_CRM_SKU_Code_Uploaded__c.replaceAll( '\\s+', '');
               
                //Action Type
                if(!ActionTypeset.contains(ao.ASI_CRM_Action_Type__c)){
                    HasError=true;
                    Msg+=ao.ASI_CRM_Action_Type__c+' Action Type is not allowed';
                }
                
                string keystr = ao.ASI_CRM_To_Code_Upload__c != null ? ao.ASI_CRM_To_Code_Upload__c: '';
                keystr+= ao.ASI_CRM_From_Code_Upload__c != null ? ao.ASI_CRM_From_Code_Upload__c: '';
                
                //******from code checking 
                if(ao.ASI_CRM_From_Code_Upload__c==null || ao.ASI_CRM_From_Code_Upload__c=='' ){
                    HasError=true;
                    Msg+='From Code cannot be blank.';
                }else if(!AccountMap.containsKey(ao.ASI_CRM_From_Code_Upload__c) && !OfftakeCustomerMap.containsKey(keystr) ){
                    HasError=true;
                    Msg+='Cannot find From Code in Salesforce.';
                }else if(OfftakeCustomerMap.containsKey(keystr) && OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_Inactive__c){
                    HasError=true;
                    Msg+='Account is Inactive.';
                } else if(AccountMap.containsKey(ao.ASI_CRM_From_Code_Upload__c) && AccountMap.get(ao.ASI_CRM_From_Code_Upload__c).ASI_HK_CRM_Inactive__c){
                    HasError=true;
                    Msg+='Account is Inactive.';
                } else if(AccountMap.containsKey(ao.ASI_CRM_From_Code_Upload__c) && !AccountMap.get(ao.ASI_CRM_From_Code_Upload__c).ASI_HK_CRM_Inactive__c){
                    ao.ASI_CRM_From_Code__c = ao.ASI_CRM_From_Code_Upload__c;   
                } else if(OfftakeCustomerMap.containsKey(keystr) && !OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_Inactive__c){ //STK Case
                    ao.ASI_CRM_From_Code__c = OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_JDE_Account_Number__c;
                } 
                
                keystr = ao.ASI_CRM_From_Code__c != null ? ao.ASI_CRM_From_Code__c: '';
                keystr+= ao.ASI_CRM_To_Code_Upload__c != null ? ao.ASI_CRM_To_Code_Upload__c: '';
                
                
                //******************To Code checking
                if(ao.ASI_CRM_To_Code_Upload__c==null || ao.ASI_CRM_To_Code_Upload__c=='' ){
                    HasError=true;
                    Msg+='To Code cannot be blank.';
                }else if(!AccountMap.containsKey(ao.ASI_CRM_To_Code_Upload__c) && !OfftakeCustomerMap.containsKey(keystr) ){
                    HasError=true;
                    Msg+='Cannot find To Code in Salesforce.';
                }else if (OfftakeCustomerMap.containsKey(keystr)){
                    ao.ASI_CRM_To_Code__c = OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_JDE_Account_Number__c;
                }else if(AccountMap.containsKey(ao.ASI_CRM_To_Code_Upload__c) ) {
                    ao.ASI_CRM_To_Code__c = AccountMap.get(ao.ASI_CRM_To_Code_Upload__c).ASI_HK_CRM_JDE_Account_Number__c;
                }
                
                //SKU checking
                keystr = ao.ASI_CRM_SG_Debit_Note_Number__c != null ? ao.ASI_CRM_SG_Debit_Note_Number__c: '';
                keystr += ao.ASI_CRM_From_Code_Upload__c != null ? ao.ASI_CRM_From_Code_Upload__c: '';
                
                if(ao.ASI_CRM_SKU_Code_Uploaded__c==null || ao.ASI_CRM_SKU_Code_Uploaded__c=='' ){
                    HasError=true;
                    Msg+='SKU Code cannot be blank.';
                }else if(!SKUMap.containsKey(ao.ASI_CRM_SKU_Code_Uploaded__c) && !SKUOutMap.containsKey(keystr)){
                    system.debug('****SKUMap***');
                    system.debug(SKUMap);
                    system.debug(SKUOutMap);
                    system.debug(ao.ASI_CRM_SKU_Code_Uploaded__c);
                    HasError=true;
                    Msg+='Cannot find SKU Code in Salesforce.';
                }
                
                //G L Date checking
                if( ao.ASI_TH_CRM_Offtake_G_L_Date__c!=null){
                    Date cutoffdate = date.today();
                    if( ao.ASI_CRM_Channel__c=='Subwholesaler'){
                        cutoffdate = GenerateCutOffDate(TWSettings.ASI_CRM_Daily_Offtake_From_Year_SWS__c, TWSettings.ASI_CRM_Daily_Offtake_From_Month_SWS__c);
                    }else{
                        cutoffdate = GenerateCutOffDate(TWSettings.ASI_CRM_Daily_Offtake_From_Year_WS__c, TWSettings.ASI_CRM_Daily_Offtake_From_Month_WS__c);
                    }
                    if(cutoffdate>ao.ASI_TH_CRM_Offtake_G_L_Date__c){
                        HasError=true;
                        Msg+='G/L Date is not within Upload Period.';
                    }
                }else if(ao.ASI_TH_CRM_Offtake_G_L_Date__c==null){
                    HasError=true;
                    Msg+='G/L Date is blank.';
                }
                
                
                if(HasError){
                    //line += ',' +Msg ; 
                    //FailedLines.add(line);
                   
                    FailedLines.add( line.substring(0,line.length()-1) + ',' +Msg +line.substring(line.length()-1,line.length())); 
                    uploadLog.ASI_MFM_Status__c = 'Process Failed';
                    uploadLog.ASI_CRM_Number_of_Failed_Records__c++;
                }else{// success
                    ao.ASI_TH_CRM_Actual_Offtake_External_ID__c = 'TW_'+ao.ASI_CRM_Action_Type__c+'_'+ao.ASI_CRM_From_Code__c+'_' +ao.ASI_CRM_To_Code__c+'_'+ao.ASI_CRM_SKU_Code_Uploaded__c+'_'+ string.valueof(ao.ASI_TH_CRM_Offtake_G_L_Date__c);
                    OfftakeKeySet.add(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c);
                    upsertList.add(line);
                     
                    
                }
                
            }
            
            
        }
        List<ASI_TH_CRM_Actual_Offtake__c> DeleteAOList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        for(ASI_TH_CRM_Actual_Offtake__c ao :[select id,ASI_CRM_Log_Id__c,ASI_TH_CRM_Actual_Offtake_External_ID__c,ASI_TH_CRM_Quantity__c,ASI_CRM_Accumulated_Times__c,ASI_CRM_Accumulation_Steps__c 
                                              from ASI_TH_CRM_Actual_Offtake__c 
                                              where ASI_TH_CRM_Actual_Offtake_External_ID__c in :OfftakeKeySet and recordType.developerName like '%TW%' and ASI_TH_CRM_Actual_Offtake_External_ID__c!=null  ])
        {
            oldOfftakeMap.put(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c ,ao);
            DeleteAOList.add(ao);                                      
        }
        string AOOwnerId =generateOwnerId(uploadLog.ASI_CRM_File_Name__c);
        
        // loop 3 : checking & generate Actual_Offtake
        for (String line : upsertList) {
            Boolean HasError = false;
            if (!String.isEmpty(line)) { // possible empty line
                List<String> values = line.removeEnd('\n').split(',');
                ASI_TH_CRM_Actual_Offtake__c ao = new ASI_TH_CRM_Actual_Offtake__c(ASI_CRM_Log_Id__c =UploadLogId ,ASI_CRM_Accumulated_Times__c=1,ASI_CRM_Mass_Uploaded__c=true, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TW_Actual_Offtake'));
                ao.ASI_CRM_Action_Type__c = values[0] != null ? values[0].trim(): null;
                
                
                ao.ASI_CRM_Action_Code__c = values[1] != null ? values[1].trim(): null;
                ao.ASI_CRM_From_Code_Upload__c  = values[2] != null ? values[2].trim(): null;
                ao.ASI_CRM_To_Code_Upload__c= values[4] != null ? values[4].trim(): null;
                ao.ASI_TH_CRM_Offtake_G_L_Date__c =  values[6] != null ? convertString2Date(values[6].trim()): null; //  like 20200731
                ao.ASI_CRM_SKU_Code_Uploaded__c = values[7] != null ? values[7].trim(): null;
                ao.ASI_CRM_SG_Debit_Note_Number__c = values[8] != null ? values[8].trim(): null; // outside sku code
                
                ao.ASI_TH_CRM_Quantity__c = (values[10] != null )? Integer.valueof(values[10].trim()): 0;//&& values[10].isNumeric()
                ao.ASI_CRM_Accumulation_Steps__c = (values[10] != null )?values[10].trim(): null;
                
                ao.ASI_CRM_Channel__c = ChannelStr;
                
                ao.ASI_CRM_Action_Type__c = ao.ASI_CRM_Action_Type__c.replaceAll('[^a-zA-Z0-9\\s+]', '');
                ao.ASI_CRM_SKU_Code_Uploaded__c =ao.ASI_CRM_SKU_Code_Uploaded__c.replaceAll('[^a-zA-Z0-9\\s+]', '');
                ao.ASI_CRM_SKU_Code_Uploaded__c = ao.ASI_CRM_SKU_Code_Uploaded__c.replaceAll( '\\s+', '');
                
                
                if(AOOwnerId!=''){
                    ao.OwnerId =AOOwnerId;
                }
                string keystr = ao.ASI_CRM_To_Code_Upload__c != null ? ao.ASI_CRM_To_Code_Upload__c: '';
                keystr+= ao.ASI_CRM_From_Code_Upload__c != null ? ao.ASI_CRM_From_Code_Upload__c: '';
                
                
                //From Code
                if(AccountMap.containsKey(ao.ASI_CRM_From_Code_Upload__c)){
                    ao.ASI_TH_CRM_From_Wholesaler__c =AccountMap.get(ao.ASI_CRM_From_Code_Upload__c).Id;
                    ao.ASI_CRM_From_Code__c =  AccountMap.get(ao.ASI_CRM_From_Code_Upload__c).ASI_HK_CRM_JDE_Account_Number__c;
                }else if(OfftakeCustomerMap.containsKey(keystr) ){
                    ao.ASI_TH_CRM_From_Wholesaler__c =OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__c;
                    ao.ASI_CRM_From_Code__c = OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_JDE_Account_Number__c;
                }
                
                
                keystr = ao.ASI_CRM_From_Code__c != null ? ao.ASI_CRM_From_Code__c: '';
                keystr+= ao.ASI_CRM_To_Code_Upload__c != null ? ao.ASI_CRM_To_Code_Upload__c: '';
                
                //To Code
                if(OfftakeCustomerMap.containsKey(keystr) ){
                    ao.ASI_TH_CRM_Outlet__c =OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__c; //ASI_CRM_JDE_Cust_No__r.ASI_MFM_Customer_Supplier_Number__c
                    if( OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_JDE_Account_Number__c!=null){
                        ao.ASI_CRM_To_Code__c = OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_HK_CRM_JDE_Account_Number__c;
                    }else if(OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_MFM_Customer_Supplier_Number__c!=null){
                        ao.ASI_CRM_To_Code__c = OfftakeCustomerMap.get(keystr).ASI_CRM_JDE_Cust_No__r.ASI_MFM_Customer_Supplier_Number__c;
                    }
                } else if(AccountMap.containsKey(ao.ASI_CRM_To_Code_Upload__c) ) {
                    ao.ASI_TH_CRM_Outlet__c =AccountMap.get(ao.ASI_CRM_To_Code_Upload__c).Id; 
                    ao.ASI_CRM_To_Code__c = AccountMap.get(ao.ASI_CRM_To_Code_Upload__c).ASI_HK_CRM_JDE_Account_Number__c;
                }
               
                
                //SKU assignment
                keystr = ao.ASI_CRM_SG_Debit_Note_Number__c != null ? ao.ASI_CRM_SG_Debit_Note_Number__c: '';
                keystr += ao.ASI_CRM_From_Code_Upload__c != null ? ao.ASI_CRM_From_Code_Upload__c: '';
                
                if(  SKUMap.containsKey(ao.ASI_CRM_SKU_Code_Uploaded__c)){
                    ao.ASI_CRM_SKU__c =SKUMap.get(ao.ASI_CRM_SKU_Code_Uploaded__c).Id;
                    ao.ASI_CRM_Item_Group__c = SKUMap.get(ao.ASI_CRM_SKU_Code_Uploaded__c).ASI_MFM_Item_Group__c;
                    ao.ASI_TH_CRM_Sub_brand__c  = SKUMap.get(ao.ASI_CRM_SKU_Code_Uploaded__c).ASI_MFM_Sub_brand__c;
                }else if(SKUOutMap.containsKey(keystr)){
                    ao.ASI_CRM_SKU__c =SKUOutMap.get(keystr).ASI_CRM_SKU__c;
                    ao.ASI_CRM_Item_Group__c = SKUOutMap.get(keystr).ASI_CRM_SKU__r.ASI_MFM_Item_Group__c;
                    ao.ASI_TH_CRM_Sub_brand__c  =SKUOutMap.get(keystr).ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                    if(ao.ASI_CRM_SKU_Code_Uploaded__c =='#N/A'){
                        ao.ASI_CRM_SKU_Code_Uploaded__c = SKUOutMap.get(keystr).ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c;
                    }
                }
                

                                
                
                if(values.size()>11){
                    ao.ASI_CRM_Commit_no__c = values[11] != null ? values[11].trim(): null;
                }
                if(values.size()>12){
                    ao.ASI_CRM_Remark__c = values[12] != null ? values[12].trim(): null;
                }
                
                if(!HasError){ // success!
                    ao.ASI_TH_CRM_Actual_Offtake_External_ID__c = 'TW_'+ao.ASI_CRM_Action_Type__c+'_'+ao.ASI_CRM_From_Code__c+'_' +ao.ASI_CRM_To_Code__c+'_'+ao.ASI_CRM_SKU_Code_Uploaded__c+'_'+ string.valueof(ao.ASI_TH_CRM_Offtake_G_L_Date__c);
                    if(!OfftakeMap.containskey(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c) ){ // put into new map 
                        OfftakeMap.put(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c,ao);
                    }else{ // old
                        ao.ASI_TH_CRM_Quantity__c += OfftakeMap.get(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c).ASI_TH_CRM_Quantity__c;
                        OfftakeMap.remove(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c);
                        OfftakeMap.put(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c,ao);
                    }
                    
                    if(oldOfftakeMap.containsKey(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c) &&  oldOfftakeMap.get(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c).ASI_CRM_Log_Id__c !=null &&
                       oldOfftakeMap.get(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c).ASI_CRM_Log_Id__c==UploadLogId)
                    {
                        ao.ASI_CRM_Accumulation_Steps__c = ao.ASI_CRM_Accumulation_Steps__c + '+ '+oldOfftakeMap.get(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c).ASI_CRM_Accumulation_Steps__c;
                        ao.ASI_TH_CRM_Quantity__c +=oldOfftakeMap.get(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c).ASI_TH_CRM_Quantity__c;
                        ao.ASI_CRM_Accumulated_Times__c +=oldOfftakeMap.get(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c).ASI_CRM_Accumulated_Times__c!=null?oldOfftakeMap.get(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c).ASI_CRM_Accumulated_Times__c:0;
                        
                        OfftakeMap.remove(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c);
                        oldOfftakeMap.remove(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c);
                        OfftakeMap.put(ao.ASI_TH_CRM_Actual_Offtake_External_ID__c,ao);
                       
                    }
                    
                    // resultAOList.add(ao); // add in upsert List
                   // SuccessLines.add(line); // add in success list
                    uploadLog.ASI_MFM_Status__c = 'Process Success';
                    SuccessLines.add(line);
                }
            }
        }
        
        if(DeleteAOList.size()>0){
            try{
                delete DeleteAOList;
            }catch( DmlException dmlError) {
                //dmlError.getMessage()
            }
            
           
        }
        
        update uploadLog;
        
        if(FailedLines.size()>0){
            UpsertAttachment(UploadLogId,String.join(FailedLines,'\n'),'Failed');
        }
        
        if(SuccessLines.size()>0){
            UpsertAttachment(UploadLogId,String.join(SuccessLines,'\n'),'Success');
        }
        
       //UpsertAttachment2(UploadLogId,SuccessLines,FailedLines);
        
        return OfftakeMap.values();
        //return resultAOList;
    }
    
    
    
    public static void UpsertAttachment( string LogId,string csvContent,string fileName){ //String csvContent = 'column1,column2\nvalue1,value2';
        fileName+='.csv';
        List<Attachment> attList = [select id,Body from Attachment where ParentId =: LogId and name =:fileName];
        if(attList.size()>0){//exist
            Attachment att = attList[0];
            string contentBody = att.Body.toString()+'\n'+csvContent;
            att.Body = Blob.valueOf(contentBody);
            
            update att;
        }else{// new ContentType ='application/vnd.ms-excel;charset=UTF-8-BOM'
            if(fileName=='Failed.csv'){
                StaticResource static_resource = [SELECT Id, SystemModStamp,Body FROM StaticResource WHERE Name = 'ASI_CRM_TW_Offtake_Failed_Template' LIMIT 1];
                Attachment att2 = new Attachment(  Name =fileName ,ParentId =LogId,description='Log file');
                string contentBody = static_resource.Body.toString()+'\n'+csvContent ;
                att2.Body = Blob.valueOf(contentBody);
                insert att2;
            }else{
                Attachment att = new Attachment( Body = Blob.valueOf(csvContent),Name = fileName,ParentId =LogId,description='Log file');
                insert att; 
            }
            
        }
        
    }
    public static date GenerateCutOffDate(string year, string month){
        
        integer yy = integer.valueOf(year);
        integer mm = integer.valueOf(month);
        if(mm==12){
            mm=1;
            yy++;
        }
        Date cutoffdate = Date.newInstance(yy, mm, 1);
        return cutoffdate;
    }
     
    @AuraEnabled(cacheable = false)
    public static string DeleteOfftakeData(String soqlStatement){ 
        String UpdateStatus = 'Success';
        ASI_CRM_TW_Settings__c my_cs = ASI_CRM_TW_Settings__c.getInstance();
        Date wsCutOff = Date.newInstance(integer.valueOf(my_cs.ASI_CRM_Daily_Offtake_From_Year_WS__c), integer.valueOf(my_cs.ASI_CRM_Daily_Offtake_From_Month_WS__c), 1);
        wsCutOff.addMonths(1);
        wsCutOff.addDays(-1);
        Date swsCutOff = Date.newInstance(integer.valueOf(my_cs.ASI_CRM_Daily_Offtake_From_Year_SWS__c), integer.valueOf(my_cs.ASI_CRM_Daily_Offtake_From_Month_SWS__c), 1);
        swsCutOff.addMonths(1);
        swsCutOff.addDays(-1);
        
        boolean UpdateOwner=false;
        boolean pass=true;
        
        
        
        List<ASI_TH_CRM_Actual_Offtake__c> soList = database.query(soqlStatement);
        
        for(ASI_TH_CRM_Actual_Offtake__c ao :soList ){
            if(ao.ASI_CRM_Channel__c=='WS'){
                if(ao.ASI_TH_CRM_Offtake_G_L_Date__c<wsCutOff){
                    pass=false;
                }
            }else{
                if(ao.ASI_TH_CRM_Offtake_G_L_Date__c<wsCutOff){
                    pass=false;
                }
            }
            if(ao.OwnerId!=UserInfo.getUserId() ){
                UpdateOwner=TRUE;
                AO.OwnerId = UserInfo.getUserId();
            }
        }

        if(pass){
            try{
                if(UpdateOwner){
                    update soList;
                }
                //UpdateStatus = 'Success: Total :' +soList.size()+' Record(s) deleted!';
                UpdateStatus = 'Success:' +soList.size();
                delete soList;
            }catch( DmlException dmlError) {
                UpdateStatus=dmlError.getMessage();
            }
        }else{
            UpdateStatus='Selected period is not within open period.';
        }
        
        return UpdateStatus;
    }
  
    public static string generateOwnerId(String FileName){
        string OwnerId='';
        if(FileName.contains('@') && FileName.contains('_')){
            List<string> FNList = FileName.split('_');
            if( FNList.size()>0){
                string userEmail = FNList[FNList.size()-1];
                userEmail =userEmail.replaceAll('.csv','');
                userEmail+='.shsb1full';
                List<user> uList = [select Id from user where username =:userEmail];
                if(uList.size()>0){
                    OwnerId = uList[0].Id;
                }
                
            }
        }
        return OwnerId;
    }
    public static Date convertString2Date(string InputStr){ // convert yyyymmdd to date
        
        integer yy =  integer.valueof(InputStr.substring(0, 4));
        integer mm =  integer.valueof(InputStr.substring(4, 6));
        integer dd =1;
        if(InputStr.length()==7 ){
             dd =integer.valueof(InputStr.substring(6, 7)); 
        }else{
             dd =integer.valueof(InputStr.substring(6, 8)); 
        }
        
        
        Date convertedDate = Date.newInstance(yy, mm, dd);
        return convertedDate;
    }
    
    public static ASI_TH_CRM_Actual_Offtake__c NewBALAOcreation(ASI_TH_CRM_Actual_Offtake__c inputAO, Date InputGlDate, string customerId,string customerCode,string jobId){
        ASI_TH_CRM_Actual_Offtake__c ao = new ASI_TH_CRM_Actual_Offtake__c(recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TW_Actual_Offtake'),
                                                                           ASI_CRM_SKU__c = inputAO.ASI_CRM_SKU__c,
                                                                           ASI_CRM_System_Calculated__c=true,
                                                                           ASI_CRM_Channel__c='Subwholesaler',ASI_CRM_Action_Code__c='U',ASI_CRM_Action_Type__c='BAL',
                                                                           ASI_TH_CRM_Offtake_G_L_Date__c = InputGlDate,
                                                                           ASI_TH_CRM_Outlet__c=customerId,
                                                                           ASI_CRM_Log_Id__c = jobId,ASI_CRM_Sync__c=false,
                                                                           ASI_TH_CRM_From_Wholesaler__c=customerId,
                                                                           ASI_CRM_To_Code__c = customerCode,
                                                                           ASI_CRM_From_Code__c= customerCode,
                                                                           ASI_CRM_Branch__c = 'Calculated from ASI_CRM_TW_OfftakeBALCalulationBatch',
                                                                           ASI_CRM_SKU_Code_Uploaded__c = inputAO.ASI_CRM_SKU_Code_Uploaded__c
                                                                          );
        ao.ASI_TH_CRM_Actual_Offtake_External_ID__c = 'TW_BAL_'+ao.ASI_CRM_To_Code__c+'_' +ao.ASI_CRM_To_Code__c+'_'+ao.ASI_CRM_SKU_Code_Uploaded__c+'_'+ string.valueof(ao.ASI_TH_CRM_Offtake_G_L_Date__c);
        system.debug('external id :'+ ao.ASI_TH_CRM_Actual_Offtake_External_ID__c);         
        return ao;
    }
    
    @AuraEnabled(cacheable = false)
    public static string OfftakeBALCalulationBatch2(String customerstr){ 
        List<string> customerList = new List<string>();
        customerList.add(customerstr);
        
        string BatchId = Database.executeBatch(new ASI_CRM_TW_OfftakeBALCalulationBatch2(customerList),1 );
        
        return BatchId;
    }
    
    @AuraEnabled(cacheable = false)
    public static string OfftakeBALCalulationBatch(String customerstr){ 
        List<string> customerList = new List<string>();
        customerList.add(customerstr);
        
        string BatchId = Database.executeBatch(new ASI_CRM_TW_OfftakeBALCalulationBatch(customerList),1 );
        
        return BatchId;
    }
    
    public static  List<String> safeSplit(String inStr, String delim) {
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;
        List<String> output = new List<String>();
        Matcher m = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        while (!m.hitEnd()) {
            while (regexFindCount < regexFindLimit && !m.hitEnd()) {
                if (m.find()) {
                    output.add(inStr.substring(lastEnd, m.start()));
                    lastEnd = m.end();
                } else {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                regexFindCount++;
            }
            m.reset(inStr);
            m.region(lastEnd, m.regionEnd());
            regexFindCount = 0;
        }
        return output;
    }
}