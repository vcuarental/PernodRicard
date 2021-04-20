<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_eForm_KR_ReturnOrder_ApprovedVF</fullName>
        <description>ASI_eForm_KR_ReturnOrder_ApprovedVF</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_eForm_Sales_Admin__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_ReturnOrder_ApprovedVF</template>
    </alerts>
    <alerts>
        <fullName>ASI_eForm_KR_ReturnOrder_RejectedVF</fullName>
        <description>ASI_eForm_KR_ReturnOrder_RejectedVF</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.eform@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_eForm_Email_Templates/ASI_eForm_KR_ReturnOrder_RejectedVF</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_ReturnOrder_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_Return_Order_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_ReturnOrder_RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_eForm_KR_ReturnOrder_RTInput</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_eForm_KR_Return_Order_Input</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI_eForm_KR_ReturnOrder_RTInput</name>
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
    <rules>
        <fullName>ASI_eForm_KR_ReturnOrder_Create</fullName>
        <actions>
            <name>ASI_eForm_KR_ReturnOrder_RTInput</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_eForm_Return_Order_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>KR Return Order</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>