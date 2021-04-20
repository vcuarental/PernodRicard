<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_VN_Visitation_Plan_Confirmation_Alert</fullName>
        <description>ASI_CRM_VN_Visitation_Plan_Confirmation_Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_Visitation_Plan_Confirmation_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Visitation_Plan_Submit_for_Confirm</fullName>
        <description>ASI CRM VN Visitation Plan Submit for Confirm</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_HK_CRM_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_Visitation_Plan_Request_for_Confirm_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_Visitation_Plan_Confirm_Alert</fullName>
        <description>ASI HK CRM Visitation Plan Confirm Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ASI_HK_CRM_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ASI_HK_CRM_Sales_Director_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_SO_Email_Templates/ASI_HK_CRM_Vistiation_Plan_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_MY_UpdateVisitationBranch</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>Owner:User.ASI_KOR_User_Branch_Name__c</formula>
        <name>ASI_CRM_MY_UpdateVisitationBranch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TH_Visitation_Target_Update</fullName>
        <field>ASI_CRM_TH_No_of_Target__c</field>
        <formula>(CASE(MOD( ASI_CRM_TH_Month_Start_Date__c - DATE(1985,6,24),7), 
  0 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,3,3,4,4,5,5,5,6,5,1), 
  1 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,3,3,4,4,4,5,4,6,5,1), 
  2 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,3,3,3,4,3,5,4,6,5,1), 
  3 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,2,3,2,4,3,5,4,6,5,1), 
  4 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,1,2,1,3,2,4,3,5,4,6,5,1), 
  5 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,0,2,1,3,2,4,3,5,4,6,5,0), 
  6 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,1,2,2,3,3,4,4,5,5,6,5,0), 
  999) 
  + 
  (FLOOR(( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c )/7)*5))*8</formula>
        <name>ASI_CRM_TH_Visitation_Target_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_VisitConcatYearMonthOwnerType</fullName>
        <field>ASI_HK_CRM_Sys_YearAndMonthAndOwner__c</field>
        <formula>ASI_HK_CRM_Year__c &amp; &apos;_&apos; &amp; TEXT( ASI_HK_CRM_Month__c ) &amp; &apos;_&apos; &amp; OwnerId &amp; &apos;_&apos; &amp;  CASE( RecordType.DeveloperName , &apos;ASI_CRM_TW_Visitation_Plan&apos;, &apos;Sales&apos;, &apos;ASI_CRM_TW_Merchandiser_Visitation_Plan&apos;,&apos;Merchan&apos;,&apos;&apos;)</formula>
        <name>ASI_CRM_TW_VisitConcatYearMonthOwnerType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_VisitationPlanName</fullName>
        <field>Name</field>
        <formula>CreatedBy.FirstName + &apos; &apos; + ASI_HK_CRM_Year__c + &apos; &apos; + LEFT(TEXT(ASI_HK_CRM_Month__c), 3) + 
CASE( RecordType.DeveloperName,&apos;ASI_CRM_TW_Visitation_Plan&apos;, &apos;-Sales&apos;, &apos;ASI_CRM_TW_Merchandiser_Visitation_Plan&apos;, &apos;-Merchandiser&apos;,&apos;&apos;)</formula>
        <name>ASI_CRM_TW_VisitationPlanName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_Manager_Email</fullName>
        <field>ASI_HK_CRM_Manager_Email__c</field>
        <formula>Owner:User.Manager.Email</formula>
        <name>ASI CRM VN Set Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_Record_Type_Submitted</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_VN_Visitation_Plan_Submitted</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM VN Set Record Type Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Set_Sys_Sumitted_False</fullName>
        <field>ASI_CRM_Sys_Submitted__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM VN Set Sys_Sumitted False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Visitation_Target_Update</fullName>
        <field>ASI_CRM_TH_No_of_Target__c</field>
        <formula>(CASE(MOD( ASI_CRM_TH_Month_Start_Date__c - DATE(1985,6,24),7), 
0 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,3,3,4,4,5,5,5,6,5,1), 
1 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,3,3,4,4,4,5,4,6,5,1), 
2 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,3,3,3,4,3,5,4,6,5,1), 
3 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,2,2,2,3,2,4,3,5,4,6,5,1), 
4 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,1,2,1,3,2,4,3,5,4,6,5,1), 
5 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,0,2,1,3,2,4,3,5,4,6,5,0), 
6 , CASE( MOD( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c ,7),1,1,2,2,3,3,4,4,5,5,6,5,0), 
999) 
+ 
(FLOOR(( ASI_CRM_TH_Month_End_Date__c - ASI_CRM_TH_Month_Start_Date__c )/7)*5))*8</formula>
        <name>ASI_CRM_VN_Visitation_Target_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_VisitConcatYearMonthOwner</fullName>
        <field>ASI_HK_CRM_Sys_YearAndMonthAndOwner__c</field>
        <formula>ASI_HK_CRM_Year__c &amp; &apos;_&apos; &amp; TEXT( ASI_HK_CRM_Month__c ) &amp; &apos;_&apos; &amp; OwnerId &amp; &apos;_&apos; &amp;  TEXT(ASI_CRM_VN_Period__c)</formula>
        <name>ASI_HK_CRM_VisitConcatYearMonthOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_VisitationPlanName</fullName>
        <field>Name</field>
        <formula>CreatedBy.FirstName + &apos; &apos; + ASI_HK_CRM_Year__c +  &apos; &apos; + LEFT(TEXT(ASI_HK_CRM_Month__c), 3)</formula>
        <name>ASI_TH_CRM_VisitationPlanName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI HK CRM Visitation Plan Confirm Alert</fullName>
        <actions>
            <name>ASI_HK_CRM_Visitation_Plan_Confirm_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>not (PRIORVALUE( ASI_HK_CRM_Confirmed__c))  &amp;&amp;  ASI_HK_CRM_Confirmed__c &amp;&amp; !BEGINS(RecordType.DeveloperName, &apos;ASI_CRM_VN&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_MY_VisitationPlanBranch</fullName>
        <actions>
            <name>ASI_CRM_MY_UpdateVisitationBranch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>MY Visitation Plan</value>
        </criteriaItems>
        <description>Update Visitation Plan Branch based on Owner User Branch Name setup</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_TH_Visitation_Target_Update</fullName>
        <actions>
            <name>ASI_CRM_TH_Visitation_Target_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.ASI_HK_CRM_Month__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>VN Visitation Plan,VN Visitation Plan Submitted</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_TW_VisitCheckDuplicateYearMonthOwner</fullName>
        <actions>
            <name>ASI_CRM_TW_VisitConcatYearMonthOwnerType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>TW Visitation Plan,TW Merchandiser Visitation Plan</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_TW_VisitationPlanName</fullName>
        <actions>
            <name>ASI_CRM_TW_VisitationPlanName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>TW Visitation Plan,TW Merchandiser Visitation Plan</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_VN_Visitation_Plan_Confirm_Alert</fullName>
        <actions>
            <name>ASI_CRM_VN_Visitation_Plan_Confirmation_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>VN Visitation Plan Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.ASI_HK_CRM_Confirmed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_VN_Visitation_Plan_Manager_Email</fullName>
        <actions>
            <name>ASI_CRM_VN_Set_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(    AND(        ISNEW(),        CONTAINS(RecordType.DeveloperName, &quot;ASI_CRM_VN&quot;)    ),    ISCHANGED(OwnerId) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_VN_Visitation_Plan_Submit_Send_Email</fullName>
        <actions>
            <name>ASI_CRM_VN_Visitation_Plan_Submit_for_Confirm</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ASI_CRM_VN_Set_Record_Type_Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_VN_Set_Sys_Sumitted_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>VN Visitation Plan</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.ASI_CRM_Sys_Submitted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>PRVN: When the Sys_Submitted checkbox is checked, send notification email to owner&apos;s manager</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_HK_CRM_VisitCheckDuplicateYearMonthOwner</fullName>
        <actions>
            <name>ASI_HK_CRM_VisitConcatYearMonthOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW() || ISCHANGED( ASI_HK_CRM_Year__c ) || ISCHANGED( ASI_HK_CRM_Month__c ) || ISCHANGED( OwnerId ) || ISCHANGED( ASI_HK_CRM_Sys_YearAndMonthAndOwner__c ) || ISCHANGED(  ASI_CRM_VN_Period__c  )) &amp;&amp; ( RecordType.DeveloperName != &apos;ASI_CRM_TW_Visitation_Plan&apos;) &amp;&amp; ( RecordType.DeveloperName != &apos;ASI_CRM_TW_Merchandiser_Visitation_Plan&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_TH_CRM_VisitationPlanName</fullName>
        <actions>
            <name>ASI_TH_CRM_VisitationPlanName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Visitation_Plan__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>TH CRM Visitation Plan</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
