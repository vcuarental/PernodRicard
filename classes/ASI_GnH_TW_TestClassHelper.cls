/*********************************************************************************
 * Name:ASI_GnH_TW_TestClassHelper
 * Description: For generating test data for TnE & GnH
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-24       Laputa: Hugo Cheung     Created
*********************************************************************************/
@isTest
public class ASI_GnH_TW_TestClassHelper {

	public static void createThreshold() {
		List<ASI_GnH_Threshold__c> thresholdList = new List<ASI_GnH_Threshold__c>();

		ASI_GnH_Threshold__c threshold1 = new ASI_GnH_Threshold__c(ASI_GnH_GnH_Type__c = 'Gifts',
			                                                       ASI_GnH_Recipient_Type__c = 'Public Official',
			                                                       ASI_GnH_Threshold_Amount__c = 5000
			                                                       );

		ASI_GnH_Threshold__c threshold2 = new ASI_GnH_Threshold__c(ASI_GnH_GnH_Type__c = 'Gifts',
			                                                       ASI_GnH_Recipient_Type__c = 'Non Public Official',
			                                                       ASI_GnH_Threshold_Amount__c = 5000
			                                                       );

		ASI_GnH_Threshold__c threshold3 = new ASI_GnH_Threshold__c(ASI_GnH_GnH_Type__c = 'Hospitality',
			                                                       ASI_GnH_Recipient_Type__c = 'Public Official',
			                                                       ASI_GnH_Threshold_Amount__c = 5000
			                                                       );

		ASI_GnH_Threshold__c threshold4 = new ASI_GnH_Threshold__c(ASI_GnH_GnH_Type__c = 'Hospitality',
			                                                       ASI_GnH_Recipient_Type__c = 'Non Public Official',
			                                                       ASI_GnH_Threshold_Amount__c = 5000
			                                                       );

		thresholdList.add(threshold1);
		thresholdList.add(threshold2);
		thresholdList.add(threshold3);
		thresholdList.add(threshold4);

		insert thresholdList;
	}

	public class AccountMappingData {

		public ASI_TnE_Account_Mapping__c accountMapping {get; set;}

		public AccountMappingData(boolean isCommit) {

			accountMapping = new ASI_TnE_Account_Mapping__c(ASI_TnE_Account_Number__c = '123456',
				                                            RecordTypeId              = Global_RecordTypeCache.getRtId('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping')
				                                            );

			if(isCommit) {
				insert accountMapping;
			}

		}

	}

	public class ClaimHeaderData {

		public ASI_TnE_ClaimHeader__c claimHeader {get; set;}

		public ClaimHeaderData(boolean isCommit) {

			claimHeader = new ASI_TnE_ClaimHeader__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header'),
				                                     CurrencyIsoCode = 'TWD', 
				                                     ASI_TnE_Payment_Option__c = 'Cash',
				                                     ASI_TnE_Status__c = 'Draft',
				                                     ASI_TnE_Date__c = Date.today().addMonths(-1)
				                                     );

			if(isCommit) {
				insert claimHeader;
			}

		}

	}

	public class ClaimDetailData {

		public ASI_TnE_ClaimDetail__c claimDetail {get; set;}

		public ClaimDetailData(boolean isCommit) {

			ClaimHeaderData claimHeaderData = new ClaimHeaderData(true);
			GnHRequestData requestData = new GnHRequestData(true);
			ExpenseCategoryAndClassificationData expenseCategoryAndClassificationData = new ExpenseCategoryAndClassificationData();

			claimDetail = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = claimHeaderData.claimHeader.Id,
				                                     ASI_TnE_Receipt_Date__c = Date.today(),
				                                     ASI_TnE_Currency__c = 'TWD',
				                                     ASI_TnE_Receipt_Amount__c = 100,
				                                     ASI_TnE_FX_Rate__c = 1,
				                                     ASI_TnE_Total_Number_Pax__c = 10,
				                                     ASI_TnE_Recipient_Type__c = 'Public Official',
				                                     ASI_TnE_Expense_Category__c = expenseCategoryAndClassificationData.expenseCategory.Id,
				                                     ASI_TnE_Expense_Classification__c = expenseCategoryAndClassificationData.expenseClassification.Id,
				                                     RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail'),
				                                     ASI_TnE_GnH_Request__c = requestData.GnHRequest.Id
				                                     );

			if(isCommit) {
				insert claimDetail;
			}

		}

		public ClaimDetailData(boolean isCommit, ASI_TnE_ClaimHeader__c claimHeader, ASI_GnH_Request__c GnHRequest, ASI_JP_TnE_Expense_Category__c expenseCategory, ASI_JP_TnE_Expense_Classification__c expenseClassification,
			                   Integer receiptAmount, Integer fxRate, Integer numberOfPAX, String recipientType) {

			claimDetail = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = claimHeader.Id,
				                                     ASI_TnE_Receipt_Date__c = Date.today(),
				                                     ASI_TnE_Currency__c = 'TWD',
				                                     ASI_TnE_Receipt_Amount__c = receiptAmount,
				                                     ASI_TnE_FX_Rate__c = fxRate,
				                                     ASI_TnE_Total_Number_Pax__c = numberOfPAX,
				                                     ASI_TnE_Recipient_Type__c = recipientType,
				                                     ASI_TnE_Expense_Category__c = expenseCategory.Id,
				                                     ASI_TnE_Expense_Classification__c = expenseClassification.Id,
				                                     RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail'),
				                                     ASI_TnE_GnH_Request__c = GnHRequest.Id
				                                     );

			if(isCommit) {
				insert claimDetail;
			}

		}

	}

	public class ExpenseCategoryAndClassificationData {	

		public ASI_JP_TnE_Expense_Category__c expenseCategory {get; set;}
		public ASI_JP_TnE_Expense_Classification__c expenseClassification {get; set;}

		public ExpenseCategoryAndClassificationData() {

			AccountMappingData accountMappingData = new AccountMappingData(true);

			expenseCategory = new ASI_JP_TnE_Expense_Category__c(Name         = 'Testing Expense Category',
				                                                 RecordTypeId = Global_RecordTypeCache.getRtId('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category')
				                                                 );

			insert expenseCategory;

			expenseClassification = new ASI_JP_TnE_Expense_Classification__c(Name                           = 'Testing Expense Classification', 
				                                                             RecordTypeId                   = Global_RecordTypeCache.getRtId('ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification'),
				                                                             ASI_JP_TnE_Expense_Category__c = expenseCategory.Id,
                                                                             ASI_JP_TnE_Account_Mapping__c  = accountMappingData.accountMapping.Id, 
                                                                             ASI_TnE_GnH_Type__c            = 'Gifts'
				                                                             );

			UserData userData1 = new UserData(false, 'testinguser1234');
			UserData userData2 = new UserData(false, 'testinguser2345');
			UserData userData3 = new UserData(false, 'testinguser3456');
			UserData userData4 = new UserData(false, 'testinguser4567');

			List<User> userList = new List<User>();

			userList.add(userData1.userObject);
			userList.add(userData2.userObject);
			userList.add(userData3.userObject);
			userList.add(userData4.userObject);

			insert userList;

			expenseClassification.ASI_TnE_Notification_Email__c   = userData1.userObject.Id;
			expenseClassification.ASI_TnE_Notification_Email_2__c = userData2.userObject.Id;
			expenseClassification.ASI_TnE_Notification_Email_3__c = userData3.userObject.Id;
			expenseClassification.ASI_TnE_Notification_Email_4__c = userData4.userObject.Id;
            
            expenseClassification.ASI_TnE_Approver__c   = userData1.userObject.Id;
			expenseClassification.ASI_TnE_Approver_2__c = userData2.userObject.Id;
			expenseClassification.ASI_TnE_Approver_3__c = userData3.userObject.Id;
			expenseClassification.ASI_TnE_Approver_4__c = userData4.userObject.Id;

			insert expenseClassification;

		}

	}

	public class GnHRequestData {

		public ASI_GnH_Request__c GnHRequest {get; set;}

		public GnHRequestData(boolean isCommit) {

			GnHRequest = new ASI_GnH_Request__c(ASI_GnH_Status__c               = 'Approved',
				                                ASI_GnH_Recipient_Type__c       = 'Public Official',
				                                ASI_GnH_Type__c                 = 'Gifts',
				                                ASI_GnH_PAX__c                  = 100,
				                                ASI_GnH_Amount_per_Recipient__c = 1000,
				                               	ASI_GnH_Benefit_Date__c         = Date.today(),
                                                RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GnH_Request__cASI_GnH_TW_Request')
				                                );

			if(isCommit) {
				insert GnHRequest;
			}

		}

		public GnHRequestData(boolean isCommit, User u) {

			GnHRequest = new ASI_GnH_Request__c(ASI_GnH_Status__c               = 'Approved',
				                                ASI_GnH_Recipient_Type__c       = 'Public Official',
				                                ASI_GnH_Type__c                 = 'Gifts',
				                                ASI_GnH_PAX__c                  = 100,
				                                ASI_GnH_Amount_per_Recipient__c = 1000,
				                               	ASI_GnH_Applicant__c            = u.Id,
				                               	ASI_GnH_Benefit_Date__c         = Date.today(),
                                                RecordTypeId                    = Global_RecordTypeCache.getRtId('ASI_GnH_Request__cASI_GnH_TW_Request')
				                                );

			if(isCommit) {
				insert GnHRequest;
			}

		}

	}

	public class GnHRouteTypeData {

		public ASI_GnH_Route_Type__c GnHRouteType {get; set;}

		public GnHRouteTypeData(boolean isCommit, User u) {

			GnHRouteType = new ASI_GnH_Route_Type__c(ASI_GnH_Company__c      = 'TestingCompany1',
			                                         ASI_GnH_Department__c   = 'TestingDepartment1',
			                                         ASI_GnH_User__c         = u.Id,
				                                     RecordTypeId            = Global_RecordTypeCache.getRtId('ASI_GnH_Route_Type__cASI_GnH_TW_Route_Type')
			                                         );

			if(isCommit) {
				insert GnHRouteType;
			}

		}

	}

	public class GnHRouteDetailData {

		public ASI_GnH_Route_Rule_Detail__c GnHRouteDetail {get; set;}

		public GnHRouteDetailData(boolean isCommit, ASI_GnH_Route_Type__c GnHRouteType) {

			GnHRouteDetail = new ASI_GnH_Route_Rule_Detail__c(ASI_GnH_Approver_Type__c = 'Line Manager',
			                                                  ASI_GnH_Route_Type__c    = GnHRouteType.Id
			                                                  );

			if(isCommit) {
				insert GnHRouteDetail;
			}

		}

		public GnHRouteDetailData(boolean isCommit, ASI_GnH_Route_Type__c GnHRouteType, User u) {

			GnHRouteDetail = new ASI_GnH_Route_Rule_Detail__c(ASI_GnH_Approver_Type__c = 'User',
			                                                  ASI_GnH_Approver_Name__c = u.Id,
			                                                  ASI_GnH_Route_Type__c    = GnHRouteType.Id
			                                                  );

			if(isCommit) {
				insert GnHRouteDetail;
			}

		}

	}

	public class UserData {

		public User userObject {get; set;}


		public UserData(boolean isCommit) {

			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

			userObject = new User(Alias             = 'tuser',
								  Email             = 'testinguser1234@testorg.com',
								  EmailEncodingKey  = 'UTF-8',
                                  LastName          = 'Testing',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey      = 'en_US',
                                  ProfileId         = p.Id,
                                  TimeZoneSidKey    = 'America/Los_Angeles',
                                  UserName          = 'testinguser1234@testorg.com'
				                  );

			if(isCommit) {
				insert userObject;
			}

		}

		public UserData(boolean isCommit, String userName) {

			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

			userObject = new User(Alias = 'tuser',
								  Email = 'testinguser1234@testorg.com',
								  EmailEncodingKey = 'UTF-8',
                                  LastName = 'Testing',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  ProfileId = p.Id, 
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  UserName = userName + '@testorg.com'
				                  );

			if(isCommit) {
				insert userObject;
			}

		}

		public UserData(boolean isCommit, String userName, Id managerId) {

			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

			userObject = new User(Alias = 'tuser',
								  Email = 'testinguser1234@testorg.com',
								  EmailEncodingKey = 'UTF-8',
                                  LastName = 'Testing',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  ProfileId = p.Id, 
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  UserName = userName + '@testorg.com',
                                  ManagerId = managerId
				                  );

			if(isCommit) {
				insert userObject;
			}

		}

		public UserData(boolean isCommit, String userName, String department, String company) {

			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

			userObject = new User(Alias = 'tuser',
								  Email = 'testinguser1234@testorg.com',
								  EmailEncodingKey = 'UTF-8',
                                  LastName = 'Testing',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  ProfileId = p.Id, 
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  UserName = userName + '@testorg.com',
                                  Department = department,
                                  CompanyName = company
				                  );

			if(isCommit) {
				insert userObject;
			}

		}

	}

}