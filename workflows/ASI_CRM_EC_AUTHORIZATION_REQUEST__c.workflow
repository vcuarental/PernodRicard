<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_CN_Alert_Legal</fullName>
        <description>Alert Legal</description>
        <protected>false</protected>
        <recipients>
            <recipient>leeann.zhou@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_EC_Authorization_Letter/ASI_CRM_EC_Autho_Approval_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_Customer_Approved</fullName>
        <description>ASI_CRM_Customer_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_EC_Authorization_Letter/ASI_CRM_EC_Autho_Approved_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_Customer_Rejected</fullName>
        <description>ASI CRM Customer Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_EC_Authorization_Letter/ASI_CRM_EC_Autho_Rejected_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_Change_Submission_Status</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Change Submission Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Change_record_type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_EC_Authorization_Request_For_AP</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change record type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Status_Approved</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI CRM Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Status_Rejected</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI CRM Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
