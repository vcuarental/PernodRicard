<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_CN_DTF_ApprovedReject</fullName>
        <description>ASI CRM CN DTF Approved Reject</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_CN_DTF_Approver_Group</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_DTF_ApprovedRejected</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_DUA_Approved</fullName>
        <description>ASI CRM CN DUA Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_CN_DUA_Level0_Approver1</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CRM_CN_DUA_Level0_Approver2</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_DUA_Approved</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_CN_DUA_Rejected</fullName>
        <description>ASI CRM CN DUA Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_CN_Email_Templates/ASI_CRM_CN_DUA_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_Approved</fullName>
        <field>ASI_CRM_CN_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>CN DTF Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_Draft</fullName>
        <field>ASI_CRM_CN_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>CN DTF Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_RT_DUA</fullName>
        <description>Data Usage Application</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_CN_Data_Usage_Application</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN DTF RT DUA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_RT_DUA_RO</fullName>
        <description>Data Usage Application</description>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_CN_Data_Usage_Application_RO</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN DTF RT DUA RO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_RT_Standard</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_CN_DTF_Standard</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN DTF RT Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_RT_readOnly</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_CN_DTF_ReadOnly</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CN DTF RT readOnly</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_Submitted</fullName>
        <description>Field Update: Status: Submitted</description>
        <field>ASI_CRM_CN_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>CN DTF Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_CN_DTF_autoApprove</fullName>
        <description>Check for auto approve</description>
        <field>ASI_CRM_CN_autoApprove__c</field>
        <literalValue>1</literalValue>
        <name>CN DTF autoApprove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
