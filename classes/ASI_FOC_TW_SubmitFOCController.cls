/*Filename:       ASI_FOC_TW_SubmitFOCController.cls
* Author:         Elufa
* Purpose:        Submit for approval - TW FOC
* Created Date:   2016-12-12
* Testing Record:  
                  One FOC will have one Plan
* -----------------------------------------------------------------------------
*/

public class ASI_FOC_TW_SubmitFOCController {
    public ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
    public String Msg {set;get;} {Msg='';}
    public Boolean IsProcess {set;get;} {IsProcess=true;}
    
    
    public ASI_FOC_TW_SubmitFOCController(apexpages.standardController sc) 
    {
        foc = (ASI_FOC_Free_Goods_Request__c)sc.getRecord();
        foc=[select Id,Name,recordTypeId,RecordType.DeveloperName,ASI_CRM_Plan__r.Name,ASI_CRM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_CRM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Over_Spending_Checking__c,ASI_CRM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c,ASI_CRM_Plan__c,ASI_CRM_Plan__r.ASI_MFM_Plan_Balance__c,ASI_CRM_Plan__r.ASI_MFM_TnE_Non_A_D_Amount__c , ASI_CRM_Plan__r.ASI_MFM_Total_without_PO_Actual_Amount__c from ASI_FOC_Free_Goods_Request__c where id = :sc.getId()];
    }
    
    public pageReference submitRequest2() {
        if(foc.RecordType.DeveloperName.contains('ASI_CRM_TW_FOC_Request')) {
            IsProcess=true;
            //SQL
            List<ASI_FOC_Request_Item__c> FOCLines = [select Id, Name,ASI_FOC_Cancel_Qty__c,ASI_FOC_Reason__c,ASI_CRM_Plan_Line_Item__r.ASI_MFM_Plan__r.name,ASI_FOC_Request_Order__c,
                                                      ASI_FOC_Request_Quantity_Bottle__c,ASI_CRM_Plan_Line_Item__r.ASI_MFM_Unit_Cost__c,ASI_CRM_TW_Amount__c,ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c,
                                                      ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c,ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c,
                                                      ASI_CRM_Plan_Line_Item__r.ASI_MFM_Plan__c,ASI_CRM_Plan_Line_Item__c,ASI_CRM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c 
                                                      from ASI_FOC_Request_Item__c where ASI_CRM_Plan_Line_Item__r.ASI_MFM_Plan__c=:foc.ASI_CRM_Plan__c ];

            IsProcess=ValdationChecking(FOCLines);
            if(IsProcess){
                submitforapproval();
                return new pageReference('/' + foc.Id);
            }else{
                Msg='☹ We cannot submit for approval.<br/>'+Msg;
                return null;
            }
        }else{
            submitforapproval();
            return new pageReference('/' + foc.Id);
        }
        
    }
    
    
    public Boolean ValdationChecking(List<ASI_FOC_Request_Item__c> FOCLines){
        Boolean isProcess = true;
        
        Decimal FOCAmount=0; 
        Decimal TotalAPFOCAmt=0;
        Decimal TotalAPPlanAmount=0;
        Decimal TotalAPPOAmount=0; //  (Approved/Completed)  
        Decimal TotalwoPOActual=foc.ASI_CRM_Plan__r.ASI_MFM_Total_without_PO_Actual_Amount__c ;  // Amount used and synced from JDE   *** Added by 2018-07-05 Linus@introv
        
        Decimal TotalADFOCAmt=0;
        
        set<Id> PlanIdSet = new set<Id>();
        Boolean HasLines= false; //for current FOC
        Map<String,ASI_MFM_Plan_Line_Item__c> PlanLineMap = new Map<String,ASI_MFM_Plan_Line_Item__c>();
        Map<String,ASI_MFM_PO_Line_Item__c> POLineMap = new Map<String,ASI_MFM_PO_Line_Item__c>();
        
        Map<String,ASI_FOC_Request_Item__c> CurrentLineMap = new Map<String,ASI_FOC_Request_Item__c>();
        
        for(ASI_FOC_Request_Item__c focl:FOCLines){
            //Checking 1: check FOC Amount 
            if(focl.ASI_CRM_TW_Amount__c ==null && focl.ASI_FOC_Request_Order__c == foc.id){
                Msg+='Free Goods Request Line (<a href="/'+focl.Id+'">'+focl.Name+ '</a>) Error:  Amount in FOC Line is Blank. <br/>';
                IsProcess=false;
            }
            
            //Checking 2: check Plan Number
            if(focl.ASI_CRM_Plan_Line_Item__c !=null){
                PlanIdSet.add(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_Plan__c);
            }else if(focl.ASI_FOC_Request_Order__c == foc.id && focl.ASI_CRM_Plan_Line_Item__c ==null){
                Msg+='Free Goods Request Line (<a href="/'+focl.Id+'">'+focl.Name+ '</a>) Error:  Please input Plan line number. <br/>';
                IsProcess=false;
            }
            
            //checking 3: check if there have  foc line 
            if(focl.ASI_FOC_Request_Order__c == foc.id){
                HasLines=true;
            }
            
            //Start calculation    
          
            if(IsProcess && focl.ASI_FOC_Request_Order__c == foc.id && focl.ASI_CRM_TW_Amount__c!=null){
                FOCAmount+=focl.ASI_CRM_TW_Amount__c;
            }
            if(IsProcess && ((focl.ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c!='Draft' && focl.ASI_FOC_Request_Order__c != foc.id ) ||focl.ASI_FOC_Request_Order__c == foc.id ) ){
                string mapkey=string.valueOf(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_Plan__c)+focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c;
                if(!CurrentLineMap.containsKey(mapkey)){
                    focl.ASI_FOC_Cancel_Qty__c=focl.ASI_CRM_TW_Amount__c;
                    focl.ASI_FOC_Reason__c='The related FOC Line is : <a href="/'+focl.Id+'">'+focl.Name+ '</a>';
                    CurrentLineMap.put(mapkey,focl);
                }else{
                    ASI_FOC_Request_Item__c FOCline= new ASI_FOC_Request_Item__c();
                    FOCline=focl.clone(false, true);
                    FOCline.ASI_FOC_Cancel_Qty__c=CurrentLineMap.get(mapkey).ASI_FOC_Cancel_Qty__c+focl.ASI_CRM_TW_Amount__c;
                    FOCline.ASI_FOC_Reason__c=focl.ASI_FOC_Reason__c+';<a href="/'+focl.Id+'">'+focl.Name+ '</a>';
                    CurrentLineMap.remove(mapkey);CurrentLineMap.put(mapkey,FOCline);
                }// AC Code level Map
                if(focl.ASI_CRM_TW_Amount__c!=NULL && (focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c.contains('A&D'))){
                    TotalADFOCAmt+=focl.ASI_CRM_TW_Amount__c;
                }else if(focl.ASI_CRM_TW_Amount__c!=NULL && ( focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c.contains('A&P') || focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c.contains('Capex')  || focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c.contains('Structure Cost') )){
                    TotalAPFOCAmt+=focl.ASI_CRM_TW_Amount__c;
                }
            }
            
        }//end of FOC Line for loop
      
        // Get Existing Plan information    ****Added by 2018-09-13 Linus@introv
        system.debug('TtlAPAmount: ' + TotalAPFOCAmt + ' TtlADAmount: ' + TotalADFOCAmt); 
        For(ASI_MFM_Plan__c plan: [Select id, ASI_CRM_FOC_Amount_w_o_A_D__c, ASI_MFM_TW_Plan_Amount_AnP__c, ASI_MFM_TW_PO_AP_Amount__c, ASI_MFM_TW_Payment_AP_Amount__c, ASI_MFM_TnE_Non_A_D_Amount__c, ASI_MFM_TW_Actual_without_PO_AnP__c , ASI_MFM_TW_Plan_Balance_AnP__c,
                                              ASI_CRM_TW_FOC_Amount_A_D__c, ASI_MFM_TW_Plan_Amount_AnD__c, ASI_MFM_TW_PO_AD_Amount__c, ASI_MFM_TW_Payment_AD_Amount__c, ASI_MFM_TW_TnE_A_D_Amount__c, ASI_MFM_TW_Actual_without_PO_AnD__c , ASI_MFM_TW_Plan_Balance_AnD__c,
                                   ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c from ASI_MFM_Plan__c where id =: foc.ASI_CRM_Plan__c])
        {            
            Decimal APamount = 0;
            Decimal ADamount = 0;
            Decimal Tolerance = plan.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c == null ? 1: 1 + plan.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c;
            // A&P Checking
            system.debug('SH: Plan Balance A&P: '+ plan.ASI_MFM_TW_Plan_Balance_AnP__c);
            //APamount = plan.ASI_MFM_TW_Plan_Balance_AnP__c * Tolerance - TotalAPFOCAmt;
            APamount = plan.ASI_MFM_TW_Plan_Amount_AnP__c * Tolerance - plan.ASI_MFM_TW_PO_AP_Amount__c - plan.ASI_MFM_TW_Payment_AP_Amount__c - plan.ASI_MFM_TnE_Non_A_D_Amount__c - plan.ASI_MFM_TW_Actual_without_PO_AnP__c - TotalAPFOCAmt;
            if(APamount<0){
                Msg+='<br/> <b>A&P Checking</b>: A&P Balance is (' + APamount.format() + ') < 0 <br/>';                 
                isProcess = false;
            }
            
            
            // A&D Checking
            system.debug('SH: Plan Balance A&D: '+ plan.ASI_MFM_TW_Plan_Balance_AnD__c);
            //ADamount = plan.ASI_MFM_TW_Plan_Balance_AnD__c * Tolerance - TotalADFOCAmt;
            ADamount = plan.ASI_MFM_TW_Plan_Amount_AnD__c * Tolerance - plan.ASI_MFM_TW_PO_AD_Amount__c - plan.ASI_MFM_TW_Payment_AD_Amount__c - plan.ASI_MFM_TW_TnE_A_D_Amount__c - plan.ASI_MFM_TW_Actual_without_PO_AnD__c - TotalADFOCAmt;
            if(ADamount<0){
                Msg+='<br/> <b>A&D Checking</b>: A&D Balance is (' + ADamount.format() + ') < 0 <br/>';                 
                isProcess = false;
            }
            
                                                  
        }
        
        
        
        if(!HasLines){
            IsProcess=false;
            Msg+='Please input FOC Line. <br/>';
        }
        return isProcess;
    }//**********************end of checking ***********************************************
        
    public void submitforapproval(){ 
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(foc.id);
        if(!Test.isRunningTest()){ Approval.ProcessResult result = Approval.process(req1);}
        
    }
    
    public pageReference goBack() {
        return new pageReference('/' + foc.id);
    }
    
    
}