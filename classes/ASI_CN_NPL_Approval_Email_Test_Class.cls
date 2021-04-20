/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class ASI_CN_NPL_Approval_Email_Test_Class {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        test.startTest();
        //testNPLApprovalEmail();
        test.stopTest();
    }
    
    static void testNPLApprovalEmail(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        user u = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true limit 1];
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :u.id limit 1];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        u.DelegatedApproverId = delU.id;
        update u;
        delU.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        delU.DelegatedApproverId = u.id;
        update delU;
        
        System.runAs(u){
          
            List<ASI_CN_NPL_NPL_Request__c> LNpl = new List<ASI_CN_NPL_NPL_Request__c>();
            ASI_CN_NPL_NPL_Request__c npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_Approval_In_Progress__c = false,
                ASI_CN_NPL_Deputy_Managing_Director__c = u.id,
                ASI_CN_NPL_Status__c  = 'Open',
                ASI_CN_NPL_Classification_Text__c = 'Class A',
                ownerid = u.id
                );
            LNpl.add(npl);
            npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_Approval_In_Progress__c = false,
                ASI_CN_NPL_Deputy_Managing_Director__c = u.id,
                ASI_CN_NPL_Status__c  = 'Open',
                ASI_CN_NPL_Classification_Text__c = 'Class A',
                ownerid = u.id
                );
            LNpl.add(npl);
            npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_Approval_In_Progress__c = false,
                ASI_CN_NPL_Deputy_Managing_Director__c = u.id,
                ASI_CN_NPL_Status__c  = 'Open',
                ASI_CN_NPL_Classification_Text__c = 'Class A',
                ownerid = u.id
                );
            LNpl.add(npl);          
            insert LNpl;
            
            List<ASI_CN_NPL_Product_Document__c> LNplPhoto = new List<ASI_CN_NPL_Product_Document__c>();
            ASI_CN_NPL_Product_Document__c nplPhoto = new ASI_CN_NPL_Product_Document__c(ASI_CN_NPL_Attach_in_Approval__c = true,
                ASI_CN_NPL_Category__c  = 'Product Photo', ASI_CN_NPL_Parent__c = LNpl[0].id);
            LNplPhoto.add(nplPhoto);
            nplPhoto = new ASI_CN_NPL_Product_Document__c(ASI_CN_NPL_Attach_in_Approval__c = true,
                ASI_CN_NPL_Category__c  = 'Packing Photo', ASI_CN_NPL_Parent__c = LNpl[0].id);
            LNplPhoto.add(nplPhoto);
            nplPhoto = new ASI_CN_NPL_Product_Document__c(ASI_CN_NPL_Attach_in_Approval__c = true,
                ASI_CN_NPL_Category__c  = 'Product Photo', ASI_CN_NPL_Parent__c = LNpl[1].id);
            LNplPhoto.add(nplPhoto);
            nplPhoto = new ASI_CN_NPL_Product_Document__c(ASI_CN_NPL_Attach_in_Approval__c = true,
                ASI_CN_NPL_Category__c  = 'Packing Photo', ASI_CN_NPL_Parent__c = LNpl[1].id);
            LNplPhoto.add(nplPhoto);
            nplPhoto = new ASI_CN_NPL_Product_Document__c(ASI_CN_NPL_Attach_in_Approval__c = true,
                ASI_CN_NPL_Category__c  = 'Product Photo', ASI_CN_NPL_Parent__c = LNpl[2].id);
            LNplPhoto.add(nplPhoto);
            nplPhoto = new ASI_CN_NPL_Product_Document__c(ASI_CN_NPL_Attach_in_Approval__c = true,
                ASI_CN_NPL_Category__c  = 'Packing Photo', ASI_CN_NPL_Parent__c = LNpl[2].id);
            LNplPhoto.add(nplPhoto);
            
            insert LNplPhoto;
            //npl.ASI_CN_NPL_Approval_In_Progress__c = true;
            //update npl;
            
            List<id> Lid = new List<id>{LNpl[0].id};
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(LNpl[0].id);
            req.setNextApproverIds(new List<id>{u.id});
            Approval.process(req);
            Lid = new List<id>{LNpl[1].id};
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(LNpl[1].id);
            req1.setNextApproverIds(new List<id>{u.id});
            Approval.process(req1);
            Lid = new List<id>{LNpl[2].id};
            Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
            req2.setObjectId(LNpl[2].id);
            req2.setNextApproverIds(new List<id>{u.id});
            Approval.process(req2);
            
            ASI_CN_NPL_HandleApprovalEmail.sendEmail(Lid,'ASI_CN_NPL_NPL_Request__c'); 
            ASI_CN_NPL_HandleApprovalEmail a = new ASI_CN_NPL_HandleApprovalEmail();
            
 
              // create a new email and envelope object
              Messaging.InboundEmail email = new Messaging.InboundEmail() ;
              Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
             
              // setup the data for the email
              email.subject = String.valueof(LNpl[0].id).substring(0,15);
              email.fromname = 'Testing';
              email.plainTextBody = 'yes\n comment ';
              env.fromAddress = 'admin@testorg.com';
              
              ASI_CN_NPL_ProcessApprovalEmail app = new ASI_CN_NPL_ProcessApprovalEmail();
              app.handleInboundEmail(email, env);
              
              email.subject = String.valueof(LNpl[1].id).substring(0,15);
              email.plainTextBody = 'no\n comment ';
              app.handleInboundEmail(email, env);
              
              email.plainTextBody = 'Invalid\n comment ';
              app.handleInboundEmail(email, env);
              
              email.subject = String.valueof(LNpl[2].id).substring(0,15);
              email.plainTextBody = 'Invalid\n comment ';
              app.handleInboundEmail(email, env);
              
              
        }
    }
}