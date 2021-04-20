public with sharing class ASI_CN_NPL_RequestNextStepController {
    public ID nplId { get; private set; }
    public ASI_CN_NPL_NPL_Request__c npl;
    public boolean succeed {get; private set;}
    
    List<ASI_CN_NPL_NPL_Forecast__c> nplForecasts = new List<ASI_CN_NPL_NPL_Forecast__c>();
    
    public ASI_CN_NPL_RequestNextStepController(ApexPages.StandardController stdController){
        this.nplId = (Id)stdController.getId();
        
        npl = [SELECT Id, ASI_CN_NPL_Status__c, ASI_CN_NPL_Classification__c, Owner.Id, RecordType.Name, RecordType.DeveloperName, CreatedById, ASI_CN_NPL_Comparable_PR_Product__c, ASI_CN_NPL_Profit_Loss__c,
            ASI_CN_NPL_Final_Proposed_Selling_Price__c FROM ASI_CN_NPL_NPL_Request__c WHERE ID = :nplId];     
            
        nplForecasts = [SELECT ASI_CN_NPL_M1__c,ASI_CN_NPL_M2__c, ASI_CN_NPL_M3__c, ASI_CN_NPL_M4__c, ASI_CN_NPL_M5__c, ASI_CN_NPL_M6__c FROM ASI_CN_NPL_NPL_Forecast__c WHERE
            New_Product_Launch_Request__c = :npl.Id AND ASI_CN_NPL_Type__c = 'Sales Volume'];
    }
    
    public pageReference goBack() {
        return new pageReference('/' + npl.id);
    }
    
    public PageReference proceedToNextStep(){
        ID currentUserID = UserInfo.getUserId();
        PageReference pageRef = null;
        Boolean noForecastValue = true;
        
        //Added by Wilken on 20140328, mandatory checking for Sales Vol Forecast
        for (ASI_CN_NPL_NPL_Forecast__c f : nplForecasts){
            if (f.ASI_CN_NPL_M1__c != null || f.ASI_CN_NPL_M2__c != null || f.ASI_CN_NPL_M3__c != null || f.ASI_CN_NPL_M4__c != null || f.ASI_CN_NPL_M5__c != null || f.ASI_CN_NPL_M6__c != null)
                noForecastValue = false;
        }
        
        System.debug('Start proceedToNextStep: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordType.Name);
        
        //*****Modified on 20130826 by Wilken: Add validation to check mandatory fields for each step before updating status and record type*****
        if (npl.RecordType.Name == 'Class C'){
             apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'Please submit for preliminary approval.'));
             succeed = false;
        }
        else if ((npl.RecordType.Name == 'Step 3.1 Class A Price Scenario' || npl.RecordType.Name == 'Step 3.1 Class B Price Scenario' || npl.RecordType.Name == 'Step 3.1 Light Price Scenario') && npl.ASI_CN_NPL_Comparable_PR_Product__c == null){
             apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'Please input all required fields at this step.'));
             succeed = false;
        }
        else if ((npl.RecordType.Name == 'Step 3.2 Class A P&L' || npl.RecordType.Name == 'Step 3.2 Class B P&L' || npl.RecordType.Name == 'Step 3.2 Light P&L') && npl.ASI_CN_NPL_Profit_Loss__c == null){
             apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'Please input Profit and Loss.'));
             succeed = false;
        }
        else if ((npl.RecordType.Name == 'Step 3.3 Class A Proposed Price' || npl.RecordType.Name == 'Step 3.3 Class B Proposed Price' || npl.RecordType.Name == 'Step 3.3 Light Proposed Price') && npl.ASI_CN_NPL_Final_Proposed_Selling_Price__c == null){
             apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'Please input Final Proposed Selling Price to T1.'));
             succeed = false;
        }
        else if ((npl.RecordType.Name == 'Step 5 Class A Vol Est' || npl.RecordType.Name == 'Step 5 Class B Vol Est' || npl.RecordType.Name == 'Step 5 Class C Vol Est' || npl.RecordType.Name == 'Step 5 Class D Vol Est' || npl.RecordType.Name == 'Step 5 Light Vol Est') && noForecastValue){
            apexpages.addMessage(new apexpages.Message(apexpages.severity.warning, 'Please input Sales Volume Forecast.'));
            succeed = false;
        }
        else {
            //Get next Record Type ID 
            ID nextRTId = getNextRecordTypeID(npl.ASI_CN_NPL_Classification__c, npl.RecordType.DeveloperName);
            
            //Update to next Record Type
            if (nextRTId != null){
                npl.RecordTypeId = nextRTId;
            }
            
            //Get next Status
            String nextStatus = getNextStatus(npl.ASI_CN_NPL_Classification__c, npl.ASI_CN_NPL_Status__c);
            
            //Update Status
            if (nextStatus != null){
                npl.ASI_CN_NPL_Status__c = nextStatus;
            }
            
            update npl;
            apexpages.addMessage(new apexpages.Message(apexpages.severity.info, 'The request status has been updated. The next handler will be notified by email.'));
            succeed = true;
        }
        
        return null;
    }
    
    @TestVisible
    private Id getNextRecordTypeID(String classification, String currentRTName){
        System.debug('Start getNextRecordTypeID, Classificiation: ' + classification + ' , CurrentRTName: ' + currentRTName);
        String nextRTName = '';
        
        if (classification == 'Class A'){
            if (currentRTName == 'ASI_CN_NPL_Step_3_1_ClassA'){    //***
                nextRTName = 'ASI_CN_NPL_Step_3_2_ClassA';                    //***
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_2_ClassA'){          //***
                nextRTName = 'ASI_CN_NPL_Step_3_3_ClassA';         //***
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_3_ClassA'){//***
                nextRTName = 'ASI_CN_NPL_LaunchPlan';                      //***
            }
            else if (currentRTName == 'ASI_CN_NPL_LaunchPlan'){            //***
                nextRTName = 'Step_5_Cass_A_Vol_Est';                  //***
            }
            else if (currentRTName == 'Step_5_Cass_A_Vol_Est'){        //***
                nextRTName = 'Step_6_Class_A_S_OP';                     //***
            }
        }
        else if (classification == 'Class B'){                          //***
            if (currentRTName == 'ASI_CN_NPL_Class_B'){                            //***
                nextRTName = 'ASI_CN_NPL_Step_3_1_ClassB';         //***
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_1_ClassB'){//***
                nextRTName = 'Step_3_2_ClassB';                    //***
            }
            else if (currentRTName == 'Step_3_2_ClassB'){          //***
                nextRTName = 'Step_3_3_ClassB';         //***
            }
            else if (currentRTName == 'Step_3_3_ClassB'){//***
                nextRTName = 'Step_5_Class_B_Vol_Est';                  //***
            }
            else if (currentRTName == 'Step_5_Class_B_Vol_Est'){        //***
                nextRTName = 'ASI_CN_NPL_Step_6_Class_B_S_OP';                     //***
            }
        }
        //*****Modified on 20130910 by Wilken: Add Steps and Status for Class C for Final Approval*****
        else if (classification == 'Class C'){                          //***
            if (currentRTName == 'ASI_CN_NPL_Step_5_Class_B_Vol_Est'){        //***
                nextRTName = 'ASI_CN_NPL_Step_6_Class_C_S_OP';                     //***
            }
        }
        //*****End Modification on 20130910*****
        //20200113:AM@Introv - CR(Opt_Auto) start
        else if (classification == 'Class D'){
            if (currentRTName == 'ASI_CN_NPL_Class_D'){
                nextRTName = 'ASI_CN_NPL_Step_3_1_Light';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_1_Light'){
                nextRTName = 'ASI_CN_NPL_Step_3_2_Light';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_2_Light'){
                nextRTName = 'ASI_CN_NPL_Step_3_3_Light';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_3_Light'){
                nextRTName = 'ASI_CN_NPL_LaunchPlan';
            }
            else if (currentRTName == 'ASI_CN_NPL_LaunchPlan'){
                nextRTName = 'ASI_CN_NPL_Step_5_Class_D';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_5_Class_D'){
                nextRTName = 'ASI_CN_NPL_Step_6_Light';
            }
        }
        else if (classification == 'Class E' || classification == 'Class F'){
            if (currentRTName == 'ASI_CN_NPL_Class_E' || currentRTName == 'ASI_CN_NPL_Class_F'){
                nextRTName = 'ASI_CN_NPL_Step_3_1_Light';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_1_Light'){
                nextRTName = 'ASI_CN_NPL_Step_3_2_Light';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_2_Light'){
                nextRTName = 'ASI_CN_NPL_Step_3_3_Light';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_3_3_Light'){
                nextRTName = 'ASI_CN_NPL_LaunchPlan';
            }
            else if (currentRTName == 'ASI_CN_NPL_LaunchPlan'){
                nextRTName = 'ASI_CN_NPL_Step_5_Light';
            }
            else if (currentRTName == 'ASI_CN_NPL_Step_5_Light'){
                nextRTName = 'ASI_CN_NPL_Step_6_Light';
            }
        }
        //20200113:AM@Introv - CR(Opt_Auto) end
        
        
        System.debug('Next RTName: ' + nextRTName);
        
        //Get Next Record Type ID
        return Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__c' + nextRTName);        
    } 
    
    @TestVisible
    private String getNextStatus(String classification, String status){
        System.debug('Start updateStatus');
        String nextStatus = '';
        
        if (classification == 'Class A'){                                           //***
            if (status == 'Pre-Approved'){                                          //***
                nextStatus = 'Waiting to Fill in Profit and Loss';                  //***
            } 
            else if (status == 'Waiting to Fill in Profit and Loss'){               //***
                nextStatus = 'Waiting to Fill in Final Proposed Selling Price';     //***
            } 
            else if (status == 'Waiting to Fill in Final Proposed Selling Price'){  //***
                nextStatus = 'Waiting to Fill in Launch Plan';                      //***
            } 
            else if (status == 'Waiting to Fill in Launch Plan'){                   //***
                nextStatus = 'Waiting to Fill in Vol Estimation';                   //***
            } 
            else if (status == 'Waiting to Fill in Vol Estimation'){                //***   
                nextStatus= 'Waiting for S&OP Alignment';                           //***
            } 
        }
        else if (classification == 'Class B'){                                      //***
            if (status == 'Pre-Approved' || status == 'Waiting to Fill in Price Scenario'){         //***
                nextStatus = 'Waiting to Fill in Profit and Loss';                  //***
            } 
            else if (status == 'Waiting to Fill in Profit and Loss'){               //***
                nextStatus = 'Waiting to Fill in Final Proposed Selling Price';     //***
            } 
            else if (status == 'Waiting to Fill in Final Proposed Selling Price'){  //***
                nextStatus = 'Waiting to Fill in Vol Estimation';                   //***
            }
            else if (status == 'Waiting to Fill in Vol Estimation'){                //***
                nextStatus = 'Waiting for S&OP Alignment';                          //***
            } 
        }
        //*****Modified on 20130826 by Wilken: Add Status for Class C to send email notification*****
        
        else if (classification == 'Class C'){
            if (status == 'Pre-Approved' || status == 'Waiting to Fill in Vol Estimation'){
                //*****Modified on 20130910 by Wilken: Add Steps and Status for Class C for Final Approval*****
                nextStatus = 'Waiting for S&OP Alignment';                          //***
            }
            //*****End Modification on 20130910*****
        }
        //*****End Modification on 20130826*****
        //20200113:AM@Introv - CR(Opt_Auto) start
        else if (classification == 'Class D' || classification == 'Class E' || classification == 'Class F'){
            if (status == 'Open'){
                nextStatus = 'Waiting to Fill in Price Scenario';
            }
            else if (status == 'Pre-Approved'){
                nextStatus = 'Waiting to Fill in Profit and Loss';
            }
            else if (status == 'Waiting to Fill in Price Scenario'){
                nextStatus = 'Waiting to Fill in Profit and Loss';
            } 
            else if (status == 'Waiting to Fill in Profit and Loss'){
                nextStatus = 'Waiting to Fill in Final Proposed Selling Price';
            }
            else if (status == 'Waiting to Fill in Final Proposed Selling Price'){
                nextStatus = 'Waiting to Fill in Launch Plan';
            }
            else if (status == 'Waiting to Fill in Launch Plan'){
                nextStatus = 'Waiting to Fill in Vol Estimation';
            }
            else if (status == 'Waiting to Fill in Vol Estimation'){
                nextStatus= 'Waiting for S&OP Alignment';
            }
        }
        //20200113:AM@Introv - CR(Opt_Auto) end
        
        System.debug('End updateStatus');
        return nextStatus;
    }
}