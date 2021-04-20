<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_eForm_KR_Donation_Approved</fullName>
        <description>ASI_eForm_KR_Donation_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_eForm_Sales_Admin__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ASI_eForm_Sys_Approver_2__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_Donation_ApprovedVF</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_Donation_Rejected</fullName>
        <description>ASI_eForm_KR_Donation_Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_Donation_RejectedVF</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_Donation_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_Donation_Request_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_Donation_RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Approved</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI_eForm_Status_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Draft</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI_eForm_Status_Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Rejected</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>ASI_eForm_Status_Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_Status_Submitted</fullName>
        <field>ASI_eForm_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI_eForm_Status_Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
