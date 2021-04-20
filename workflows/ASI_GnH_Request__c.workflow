<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_GnH_KR_Offer_Send_Approved_Notification</fullName>
        <description>ASI GnH KR Offer Send Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_GnH_Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_GnH_Email_Template/ASI_GnH_KR_Offer_Approved_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_GnH_KR_Offer_Send_Rejected_Notification</fullName>
        <description>ASI GnH KR Offer Send Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_GnH_Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_GnH_Email_Template/ASI_GnH_KR_Offer_Rejected_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_GnH_KR_Receive_Rejected_HR_Reminder_Notification</fullName>
        <description>ASI GnH KR Receive Rejected HR Reminder Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_GnH_KR_HR_Users</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_GnH_Email_Template/ASI_GnH_KR_Rece_Reject_HR_Remind_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_GnH_KR_Receive_Send_Approved_Notification</fullName>
        <description>ASI GnH KR Receive Send Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_GnH_Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_GnH_Email_Template/ASI_GnH_KR_Receive_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_GnH_KR_Receive_Send_Rejected_Notification</fullName>
        <description>ASI GnH KR Receive Send Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_GnH_Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_GnH_Email_Template/ASI_GnH_KR_Receive_Rejected_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_GnH_TW_Send_Approved_Notification</fullName>
        <description>ASI GnH TW Send Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_GnH_Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_GnH_Email_Template/ASI_GnH_TW_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_GnH_TW_Send_Rejected_Notification</fullName>
        <description>ASI GnH TW Send Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_GnH_Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_GnH_Email_Template/ASI_GnH_TW_Rejected_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_GnH_KR_Set_Offer_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_GnH_KR_Offer_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set KR Offer Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_KR_Set_Rec_Type_Offer_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_GnH_KR_Offer_Request_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type GnH KR Offer Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_KR_Set_Rec_Type_Receiv_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_GnH_KR_Receive_Request_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type GnH KR Receive Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_Set_Rejected_Date</fullName>
        <field>ASI_GnH_Rejected_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Rejected Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_Set_Status_Approved</fullName>
        <field>ASI_GnH_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Set Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_Set_Status_Draft</fullName>
        <field>ASI_GnH_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Set Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_Set_Status_Rejected</fullName>
        <field>ASI_GnH_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Set Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_Set_Status_Submitted</fullName>
        <field>ASI_GnH_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Set Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_Set_Submitted_Date_Today</fullName>
        <field>ASI_GnH_Submitted_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Submitted Date Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_Set_Sys_Allow_Submit_Aprv_False</fullName>
        <field>ASI_GnH_Sys_Allow_Submit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Set Sys Allow Submit Approval False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_TW_Set_Rec_Type_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_GnH_TW_Request_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type GnH TW Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_GnH_TW_Set_Rec_Type_Standard</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_GnH_TW_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type GnH TW Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_GnH_Free_GnH_Request</fullName>
        <actions>
            <name>ASI_GnH_TW_Set_Rec_Type_Standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Change record type of the G&amp;H if user change the status back to Draft:
- PRTW</description>
        <formula>CONTAINS(RecordType.DeveloperName, &quot;ASI_GnH_TW_Request_Read_Only&quot;) &amp;&amp;  ISCHANGED(ASI_GnH_Status__c) &amp;&amp;  ISPICKVAL(ASI_GnH_Status__c, &quot;Draft&quot;) &amp;&amp;  ISPICKVAL(PRIORVALUE(ASI_GnH_Status__c), &quot;Approved&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_GnH_KR_Offer_Approved_to_Draft</fullName>
        <actions>
            <name>ASI_GnH_KR_Set_Offer_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(     CONTAINS(RecordType.DeveloperName, &quot;ASI_GnH_KR_Offer_Request_Read_Only&quot;),     ISPICKVAL(PRIORVALUE(ASI_GnH_Status__c), &quot;Approved&quot;),     ISPICKVAL(ASI_GnH_Status__c, &quot;Draft&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
